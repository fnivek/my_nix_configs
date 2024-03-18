{ inputs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.x86_64-linux.hyprland;
    # package = inputs.hyprland.packages.hyprland;
    # xwayland.enable = true;
    # systemd.enable = true;
    # enableNvidiaPatches = true;
    plugins = [
      # inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
      inputs.hy3.packages.x86_64-linux.hy3
    ];

    settings = {
      # Variables.
      "$mod" = "SUPER";

      # General settings.
      general = {
        layout = "hy3";
        resize_on_border = true;
      };

      # Regular bind.
      bind = [
        # Launch programs
        "$mod, Return, exec, kitty"
        # Fullscreen
        "$mod, f, fullscreen, 1"
        "$mod SHIFT, f, fullscreen, 0"
        # Float
        "$mod, Space, togglefloating"
        # Kill
        "$mod, Q, hy3:killactive"
        # Launcher
        "$mod, D, exec, pkill wofi || wofi --show drun"
        # Layout
        "$mod, v, hy3:makegroup, v"
        "$mod, e, hy3:changegroup, opposite"
        "$mod, w, hy3:makegroup, tab"
        "$mod, a, hy3:changefocus, raise"
        "$mod, c, hy3:changefocus, lower"
      ]
      ++ (
        # Workspace motion
        builtins.concatLists (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
            ]
        ) 10)
      )
      ++ (
        # Motions
        builtins.concatMap (x:
          [
            "$mod, ${x.key}, hy3:movefocus, ${x.dir}"
            "$mod SHIFT, ${x.key}, hy3:movewindow, ${x.dir}"
          ]
        )
        [
          { key = "j"; dir = "d"; }
          { key = "k"; dir = "u"; }
          { key = "h"; dir = "l"; }
          { key = "l"; dir = "r"; }
          { key = "down"; dir = "d"; }
          { key = "up"; dir = "u"; }
          { key = "left"; dir = "l"; }
          { key = "right"; dir = "r"; }
        ]
      );
    };
  };
}

