{
  description = "Kevin\'s base non-project specific dev environment.";

  # I want to use the most up to date inputs out there.
  # Run `nix flake update` to pull in the latest.
  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*";
  };

  outputs =
    {
      self,
      flake-schemas,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      schemas = flake-schemas.schemas;

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            # So I know I'm in a KevDev shell.
            shellHook = ''
              export HELIX_RUNTIME=${pkgs.helix}/lib/runtime
              export HELIX_DISABLE_AUTO_GRAMMAR_BUILD=1
              printf "\e[38;2;0;255;000m▗▖ ▗▖▗▞▀▚▖▄   ▄ ▗▄▄▄  ▗▞▀▚▖▄   ▄\e[0m\n"
              printf "\e[38;2;0;170;085m▐▌▗▞▘▐▛▀▀▘█   █ ▐▌  █ ▐▛▀▀▘█   █\e[0m\n"
              printf "\e[38;2;0;085;170m▐▛▚▖ ▝▚▄▄▖ ▀▄▀  ▐▌  █ ▝▚▄▄▖ ▀▄▀ \e[0m\n"
              printf "\e[38;2;0;000;255m▐▌ ▐▌           ▐▙▄▄▀            \e[0m\n"
            '';

            packages = with pkgs; [
              # Version control
              git
              # Pull stuff from the internet.
              curl
              wget
              # Helix and its language servers.
              helix
              nixfmt-rfc-style
              nil
              nixd
              vscode-langservers-extracted
              yaml-language-server
              # Ansible is broken see https://github.com/ansible/vscode-ansible/issues/1144
              # ansible-language-server
              taplo
              bash-language-server
              clang
              clang-tools
              # Go task
              go-task
              # Misc
              bat
            ];
          };
        }
      );
    };
}
