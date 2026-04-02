# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All day-to-day operations are run via `task` (go-task). A devbox dev shell (`task dev-zshell` or `devbox shell`) provides pinned versions of `nil`, `nixfmt-rfc-style`, `statix`, `go-task`, and `nixos-rebuild`.

| Task | Command |
|------|---------|
| Apply config on current machine | `task switch` |
| Build current machine (no activate) | `task build` |
| Build all machines | `task build-all` |
| Format all `.nix` files | `task format` |
| Lint (format check + statix) | `task lint` |
| Watch for changes and lint/build | `task watch` |
| Update all flake inputs | `task update` |
| Garbage collect store | `task garbage-collect` |
| Read home-manager news | `task hm-news` |

`task switch` and `task build` auto-detect the current `$USER@$HOSTNAME` and dispatch to the correct home-manager or NixOS path. On NixOS hosts they call `sudo nixos-rebuild switch`; on Ubuntu/home-manager hosts they call `home-manager switch --flake .#<user>@<host>`.

## Architecture

This repo uses the [dendritic pattern](https://github.com/mightyiam/dendritic): every `.nix` file under `modules/` (except those in `_`-prefixed directories) is auto-imported as a flake-parts top-level module via `import-tree`. `flake.nix` is a thin entry point — it only declares inputs and calls `mkFlake`.

### Directory layout

```
modules/
  options.nix          # declares myConfig.* top-level options
  hosts-assembler.nix  # reads myConfig.hosts and produces flake outputs
  hagrid.nix           # registers hagrid host, lists its HM modules
  hedwig.nix           # registers hedwig host
  mss01-t4.nix         # registers kevinfrench@MSS01-T4
  mss01-wks62.nix      # registers kdfrench@MSS01-WKS62.motivss.local
  _nixos/              # NixOS system configs (excluded from auto-import)
    hagrid/default.nix
    hedwig/default.nix
    fonts.nix          # shared NixOS fonts module
  _hm/                 # Home-manager feature modules (excluded from auto-import)
    home-base.nix      # shared HM base (packages, colorScheme, services)
    host-settings.nix  # declares hostSettings HM option
    i3.nix, helix.nix, git.nix, zsh.nix ...
```

`_`-prefixed directories are ignored by `import-tree` by default (`/_` path convention). Files in `_nixos/` and `_hm/` are referenced explicitly by path from the host registration files.

### How a host is defined

Each `modules/<hostname>.nix` is a flake-parts module that sets `myConfig.hosts.<name>`:

```nix
_: {
  myConfig.hosts.hagrid = {
    isNixOs = true;
    username = "kdfrench";
    hasBattery = false;
    hasNvidiaGpu = true;
    isPersonal = true;
    nixosModules = [ ./_nixos/hagrid/default.nix ];
    hmModules = [
      ./_hm/home-base.nix
      ./_hm/i3.nix
      # ... opt-in feature modules
    ];
  };
}
```

`hosts-assembler.nix` reads all `myConfig.hosts` entries and builds `nixosConfigurations` (for `isNixOs = true`) or `homeConfigurations` (for `isNixOs = false`).

### Host settings system

`modules/_hm/host-settings.nix` declares `hostSettings` as a home-manager option with three boolean flags:

| Flag | Purpose |
|------|---------|
| `hasBattery` | Adds battery block to i3status-rust bar |
| `hasNvidiaGpu` | Adds nvidia_gpu block to i3status-rust bar |
| `isPersonal` | Adds Steam to packages |

The assembler injects these values automatically from `myConfig.hosts.*` — no need to set them manually in HM modules.

### Eliminating specialArgs

`extraSpecialArgs`/`specialArgs` are replaced by `_module.args` injected inline by `hosts-assembler.nix`. HM modules receive `inputs` and `pkgs-unstable` as regular function parameters. `pam-shim` and `nix-colors` modules are included in the common module list in the assembler for all hosts; `pamShim.enable` is set automatically based on `isNixOs`.

### Key inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` (25.11) | Stable channel, used for most packages |
| `nixpkgs-unstable` | Passed as `pkgs-unstable`; provides `devbox` |
| `home-manager` (release-25.11) | Manages user environment on both NixOS and Ubuntu |
| `nix-colors` | `colorScheme` option + catppuccin palette definitions |
| `pam-shim` | Enables PAM tools (i3lock, etc.) on non-NixOS systems |
| `i3_scripts` | External i3 helper scripts, accessed via `inputs.i3_scripts` in `_hm/i3.nix` |
| `flake-parts` | Top-level module system evaluation |
| `import-tree` | Auto-discovers and imports all flake-parts modules under `modules/` |

### Adding a new host

1. Create `modules/<hostname>.nix` (a flake-parts module) declaring `myConfig.hosts.<key>` with the host flags and `hmModules` list.
2. For **NixOS**: add `modules/_nixos/<hostname>/default.nix` and `hardware-configuration.nix`; reference `default.nix` in `nixosModules`.
3. For **home-manager only**: use `"<user>@<hostname>"` as the key — it becomes the `homeConfigurations` output key automatically.
4. Add the corresponding `task switch-<user>-<host>` and `build-<user>-<host>` dispatch entries in `Taskfile.yml`.
5. No changes to `flake.nix` needed — `import-tree` picks up the new file automatically.
