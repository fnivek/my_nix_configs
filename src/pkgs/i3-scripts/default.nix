# Kevin's i3 helper scripts, built from pyproject.toml with nixpkgs' python
# packages (no poetry2nix).
{ pkgs }:
let
  i3-scripts = pkgs.python3Packages.buildPythonApplication {
    pname = "i3_scripts";
    version = "0.1.0";
    pyproject = true;
    src = ./.;
    build-system = [ pkgs.python3Packages.poetry-core ];
    dependencies = with pkgs.python3Packages; [
      i3ipc
      click
    ];
    pythonImportsCheck = [
      "i3_scripts"
      "i3_focus"
    ];
  };
in
{
  inherit i3-scripts;

  # Ensures only one focus history server is ever running.
  focus-history-server-launch = pkgs.writeShellApplication {
    name = "focus_history_server_launch";
    runtimeInputs = [ i3-scripts ];
    text = ''
      # Kill any existing process.
      pid="$(pgrep -f focus_history_server-wrapped || true)"
      if [ -n "$pid" ]; then kill -15 "$pid"; fi
      # Start the server.
      focus_history_server
    '';
  };

  toggle-touchpad = pkgs.writeShellApplication {
    name = "toggle-touchpad";
    text = builtins.readFile ./toggle-touchpad;
  };

  toggle-displays = pkgs.writeShellApplication {
    name = "toggle-displays";
    text = builtins.readFile ./toggle-displays;
  };
}
