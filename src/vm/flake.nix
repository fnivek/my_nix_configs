{
  description = "Ubuntu Server VM (QEMU + cloud-init) with a direnv dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Shared by every command: where the VM lives and how to reach it.
      common = ''
        VM_DIR="''${VM_DIR:-$PWD/.vm}"
        SSH_PORT="''${VM_SSH_PORT:-2222}"
        PIDFILE="$VM_DIR/qemu.pid"
        # shellcheck disable=SC2034  # not every command uses every shared variable
        QMP_SOCK="$VM_DIR/qmp.sock"
        KNOWN_HOSTS="$VM_DIR/known_hosts"
        vm_running() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }
        # shellcheck disable=SC2034
        ssh_opts=(-p "$SSH_PORT" -o UserKnownHostsFile="$KNOWN_HOSTS" -o StrictHostKeyChecking=accept-new)
      '';

      start-vm = pkgs.writeShellApplication {
        name = "start-vm";
        runtimeInputs = with pkgs; [ qemu cloud-utils curl coreutils gawk ];
        text = common + ''
          RELEASE="''${UBUNTU_RELEASE:-noble}"   # noble = 24.04 LTS
          DISK_SIZE="''${VM_DISK_SIZE:-20G}"
          MEM="''${VM_MEMORY:-8192}"
          CPUS="''${VM_CPUS:-2}"
          VM_PASSWORD="''${VM_PASSWORD:-ubuntu}"

          if vm_running; then
            echo "!! VM already running (pid $(cat "$PIDFILE")). Use assistant-vm to connect, stop-vm to stop." >&2
            exit 1
          fi

          mkdir -p "$VM_DIR"
          IMG_NAME="$RELEASE-server-cloudimg-amd64.img"
          BASE="$VM_DIR/$IMG_NAME"
          DISK="$VM_DIR/disk.qcow2"
          SEED="$VM_DIR/seed.img"
          URL="https://cloud-images.ubuntu.com/$RELEASE/current"

          # 1. Download + verify the official Ubuntu Server cloud image (once).
          if [ ! -f "$BASE" ]; then
            echo ">> Downloading $IMG_NAME"
            curl -fL --progress-bar -o "$BASE.part" "$URL/$IMG_NAME"
            expected=$(curl -fsSL "$URL/SHA256SUMS" | awk -v f="*$IMG_NAME" '$2 == f { print $1 }')
            actual=$(sha256sum "$BASE.part" | cut -d' ' -f1)
            if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
              echo "!! Checksum mismatch for $IMG_NAME" >&2
              rm -f "$BASE.part"
              exit 1
            fi
            mv "$BASE.part" "$BASE"
          fi

          # 2. Copy-on-write overlay so the base image stays pristine.
          if [ ! -f "$DISK" ]; then
            qemu-img create -q -f qcow2 -F qcow2 -b "$BASE" "$DISK" "$DISK_SIZE"
          fi

          # 3. cloud-init seed: user "ubuntu" with a password, SSH password auth on.
          if [ ! -f "$SEED" ]; then
            cat > "$VM_DIR/user-data" <<EOF
          #cloud-config
          hostname: ubuntu-vm
          password: $VM_PASSWORD
          chpasswd: { expire: false }
          ssh_pwauth: true
          EOF
            cloud-localds "$SEED" "$VM_DIR/user-data"
          fi

          # 4. Boot. Use KVM if available, otherwise fall back to (slow) emulation.
          if [ -w /dev/kvm ]; then
            accel=(-machine "q35,accel=kvm" -cpu host)
          else
            echo ">> /dev/kvm not available, using software emulation (slow)"
            accel=(-machine "q35,accel=tcg" -cpu max)
          fi

          echo ">> Login: ubuntu / $VM_PASSWORD   SSH: vm-ssh   Assistant: assistant-vm"
          echo ">> Stop cleanly from another terminal: stop-vm   (Ctrl-a x here is a hard power cut)"
          exec qemu-system-x86_64 \
            "''${accel[@]}" \
            -smp "$CPUS" -m "$MEM" \
            -nographic \
            -pidfile "$PIDFILE" \
            -qmp unix:"$QMP_SOCK",server=on,wait=off \
            -drive if=virtio,file="$DISK",format=qcow2 \
            -drive if=virtio,file="$SEED",format=raw \
            -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:"$SSH_PORT"-:22
        '';
      };

      # Clean shutdown: presses the virtual ACPI power button, so Ubuntu stops
      # its services and flushes the disk, then waits for QEMU to exit.
      stop-vm = pkgs.writeShellApplication {
        name = "stop-vm";
        runtimeInputs = with pkgs; [ socat coreutils ];
        text = common + ''
          TIMEOUT="''${VM_STOP_TIMEOUT:-120}"
          if ! vm_running; then
            echo ">> VM is not running"
            exit 0
          fi
          pid=$(cat "$PIDFILE")
          qmp() { printf '%s\n' '{"execute":"qmp_capabilities"}' "{\"execute\":\"$1\"}" | socat - UNIX-CONNECT:"$QMP_SOCK" >/dev/null; }

          if [ "''${1:-}" = "--force" ]; then
            echo ">> Forcing QEMU to quit (like pulling the plug)"
            qmp quit 2>/dev/null || kill "$pid" 2>/dev/null || true
            exit 0
          fi

          echo ">> Asking the VM to shut down (ACPI power button)"
          qmp system_powerdown
          for _ in $(seq "$TIMEOUT"); do
            if ! kill -0 "$pid" 2>/dev/null; then
              echo ">> VM stopped"
              exit 0
            fi
            sleep 1
          done
          echo "!! VM still running after $TIMEOUT s. Try again, or: stop-vm --force" >&2
          exit 1
        '';
      };

      # Open the assistant inside a tmux session in the VM, with the portal
      # tunnelled to http://127.0.0.1:8081/ on this machine.
      # Detach with Ctrl-b d (the assistant keeps running), run again to reattach.
      # Extra arguments go to the assistant, e.g. `assistant-vm --continue`
      # after a reboot picks up the last conversation.
      assistant-vm = pkgs.writeShellApplication {
        name = "assistant-vm";
        runtimeInputs = with pkgs; [ openssh coreutils ];
        text = common + ''
          PORTAL_PORT="''${VM_PORTAL_PORT:-8081}"
          if ! vm_running; then
            echo "!! VM is not running. Start it with start-vm first." >&2
            exit 1
          fi
          remote="tmux new-session -A -s assistant ~/.local/bin/assistant"
          if [ "$#" -gt 0 ]; then
            remote="$remote $(printf '%q ' "$@")"
          fi
          echo ">> Portal: http://127.0.0.1:$PORTAL_PORT/   Detach: Ctrl-b d"
          exec ssh -t "''${ssh_opts[@]}" \
            -L "127.0.0.1:$PORTAL_PORT:127.0.0.1:8081" \
            ubuntu@localhost "$remote"
        '';
      };

      # A plain shell in the VM (or run one command: vm-ssh uptime).
      vm-ssh = pkgs.writeShellApplication {
        name = "vm-ssh";
        runtimeInputs = with pkgs; [ openssh ];
        text = common + ''
          exec ssh "''${ssh_opts[@]}" ubuntu@localhost "$@"
        '';
      };

      # Wipes the VM disk: the assistant, its memory and everything installed.
      reset-vm = pkgs.writeShellApplication {
        name = "reset-vm";
        runtimeInputs = with pkgs; [ coreutils ];
        text = common + ''
          if vm_running; then
            echo "!! VM is running. Stop it first with stop-vm." >&2
            exit 1
          fi
          echo "!! This deletes the VM disk: the assistant, its memory, the portal and everything you installed."
          read -r -p "Type 'reset' to continue: " answer
          if [ "$answer" != "reset" ]; then
            echo ">> Cancelled"
            exit 1
          fi
          rm -f "$VM_DIR/disk.qcow2" "$VM_DIR/seed.img" "$VM_DIR/user-data" "$KNOWN_HOSTS"
          echo ">> VM disk reset (downloaded base image kept)"
        '';
      };
    in
    {
      packages.${system} = {
        inherit start-vm stop-vm assistant-vm vm-ssh reset-vm;
        default = start-vm;
      };

      apps.${system}.default = {
        type = "app";
        program = "${start-vm}/bin/start-vm";
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ start-vm stop-vm assistant-vm vm-ssh reset-vm pkgs.qemu pkgs.cloud-utils ];
        shellHook = ''
          echo "Ubuntu VM shell: start-vm | assistant-vm | stop-vm | vm-ssh | reset-vm (wipes the disk)"
        '';
      };
    };
}
