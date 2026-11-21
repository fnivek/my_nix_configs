# Kevin's base, non-project-specific dev environment.
# Exposed by the repo flake as devShells.<system>.kev-dev.
{ pkgs }:
let
  kevdev-refresh = pkgs.callPackage ./pkgs/kevdev-refresh { };
in
{
  inherit kevdev-refresh;
  shell =
    let
      py = pkgs.python3;
      pyEnv = py.withPackages (
        ps: with ps; [
          pytest
          pytest-cov
          pytest-mock

          black
          flake8
          pylint
          pycodestyle
          ruff
          pyflakes
          yapf
          autopep8
          mccabe

          python-lsp-server
          jedi

          sphinx
          sphinx-autodoc-typehints
          sphinx-rtd-theme
        ]
      );
    in
    pkgs.mkShell {
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
        # Python
        py
        pyEnv
        poetry
        ty
        # Helix and its language servers.
        helix
        nixfmt
        nil
        nixd
        vscode-langservers-extracted
        vscode-json-languageserver
        yaml-language-server
        # Ansible is broken see https://github.com/ansible/vscode-ansible/issues/1144
        # ansible-language-server
        taplo
        tombi
        bash-language-server
        clang
        clang-tools
        docker-language-server
        hadolint
        dockerfmt
        marksman
        markdown-oxide
        rumdl
        # Go task
        go-task
        # Misc
        bat
        # environment control
        direnv
        nix-direnv
        # kevdev cli tools
        kevdev-refresh
      ];
    };
}
