{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # package = pkgs.hyprland;
    # package = inputs.hyprland.packages.hyprland;
    # xwayland.enable = true;
    # systemd.enable = true;
    enableNvidiaPatches = true;
    # plugins = [
    #   inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
    # ];

    settings = {
      "$mod" = "SUPER";
      bind = [
        # Launch programs
        "$mod, Return, exec, kitty"
        # Fullscreen
        "$mod, f, fullscreen, 1"
        "$mod SHIFT, f, fullscreen, 0"
        # Float
        "$mod, Space, togglefloating"
        # Kill
        "$mod, Q, killactive"
        # Launcher
        "$mod, D, exec, pkill wofi || wofi --show drun"
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
            "$mod, ${x.key}, movefocus, ${x.dir}"
            "$mod SHIFT, ${x.key}, movewindow, ${x.dir}"
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

