# Assistant VM
Runs the assistant in an Ubuntu Server VM (QEMU + cloud-init). Commands come from the repo flake:

```
nix develop github:fnivek/my_nix_configs#vm   # shell with every command below
nix run github:fnivek/my_nix_configs#start-vm
```

| Command | What it does |
|---|---|
| `start-vm` | Downloads and verifies the Ubuntu cloud image once, then boots the VM |
| `assistant-vm` | Opens the assistant in tmux inside the VM, with the portal tunnelled to `127.0.0.1:8081` |
| `vm-ssh` | A shell in the VM, or one command: `vm-ssh uptime` |
| `stop-vm` | Clean ACPI shutdown, `--force` to pull the plug |
| `reset-vm` | Deletes the VM disk (asks first) |

The VM's disk lives in `$VM_DIR`, which defaults to `./.vm` in the folder you run the command from.
Always start it from the same folder, or set `VM_DIR`, or you get a fresh VM.

## Settings
Environment variables read by `start-vm`:

| Variable | Default | Notes |
|---|---|---|
| `VM_MEMORY` | `24576` | MiB, read at every boot |
| `VM_CPUS` | `4` | read at every boot |
| `VM_DISK_SIZE` | `250G` | at every start, grows the disk to this size (never shrinks) |
| `VM_SSH_PORT` | `2222` | host port forwarded to the VM's ssh |
| `UBUNTU_RELEASE` | `noble` | 24.04 LTS |
