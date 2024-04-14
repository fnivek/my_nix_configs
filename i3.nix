{ config, lib, pkgs, ... }:
let
  mod = "Mod4";
  dirs = [
    { key = "j";     dir = "down"; }
    { key = "k";     dir = "up"; }
    { key = "h";     dir = "left"; }
    { key = "l";     dir = "right"; }
    { key = "Down";  dir = "down"; }
    { key = "Up";    dir = "up"; }
    { key = "Left";  dir = "left"; }
    { key = "Right"; dir = "right"; }
  ];
in {
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;

      fonts = ["DejaVu Sans Mono, FontAwesome 6"];

      keybindings = lib.mkDefault ({
        "${mod}+Shift+q" = "kill";

        "${mod}+v" = "split v";
        "${mod}+f" = "fullscreen toggle";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        "${mod}+a" = "focus parent";
        "${mod}+c" = "focus child";

        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" =
          "move container to workspace number 1";
        "${mod}+Shift+2" =
          "move container to workspace number 2";
        "${mod}+Shift+3" =
          "move container to workspace number 3";
        "${mod}+Shift+4" =
          "move container to workspace number 4";
        "${mod}+Shift+5" =
          "move container to workspace number 5";
        "${mod}+Shift+6" =
          "move container to workspace number 6";
        "${mod}+Shift+7" =
          "move container to workspace number 7";
        "${mod}+Shift+8" =
          "move container to workspace number 8";
        "${mod}+Shift+9" =
          "move container to workspace number 9";
        "${mod}+Shift+0" =
          "move container to workspace number 10";

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+Shift+e" =
          "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

        "${mod}+r" = "mode resize";
      }
      //
      (builtins.listToAttrs (
        map (dir: {name = "${mod}+${dir.key}"; value = "focus ${dir.dir}"; }) dirs ))
      //
      (builtins.listToAttrs (
        map (dir: {name = "${mod}+Shift+${dir.key}"; value = "move ${dir.dir}"; }) dirs ))
      //
      {
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        "${mod}+Shift+x" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";
      });

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
        }
      ];
    };
  };
}
