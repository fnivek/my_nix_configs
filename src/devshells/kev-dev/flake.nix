{
  description = "Kevin\'s base non-project specific dev environment.";

  # I want to use the most up to date inputs out there.
  # Run `nix flake update` to pull in the latest.
  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*";
  };

  outputs = { self, flake-schemas, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in {
      schemas = flake-schemas.schemas;

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          # So I know I'm in a KevDev shell.
          shellHook = ''
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
            nixpkgs-fmt
            nil
            nixd
            vscode-langservers-extracted
            yaml-language-server
            ansible-language-server
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
      });
    };
}
