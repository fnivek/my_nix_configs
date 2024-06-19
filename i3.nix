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
# Colors (https://github.com/catppuccin/i3/blob/main/themes/catppuccin-mocha)
  rosewater = "#f5e0dc";
  flamingo  = "#f2cdcd";
  pink      = "#f5c2e7";
  mauve     = "#cba6f7";
  red       = "#f38ba8";
  maroon    = "#eba0ac";
  peach     = "#fab387";
  yellow    = "#f9e2af";
  green     = "#a6e3a1";
  teal      = "#94e2d5";
  sky       = "#89dceb";
  sapphire  = "#74c7ec";
  blue      = "#89b4fa";
  lavender  = "#b4befe";
  text      = "#cdd6f4";
  subtext1  = "#bac2de";
  subtext0  = "#a6adc8";
  overlay2  = "#9399b2";
  overlay1  = "#7f849c";
  overlay0  = "#6c7086";
  surface2  = "#585b70";
  surface1  = "#45475a";
  surface0  = "#313244";
  base      = "#1e1e2e";
  mantle    = "#181825";
  crust     = "#11111b";
in {
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      # Set colors
      colors = lib.mkDefault ({
        focused = {
          border = "${lavender}";
          background = "${base}";
          text = "${text}";
          indicator = "${rosewater}";
          childBorder = "${lavender}";
        };
        focusedInactive = {
          border = "${overlay0}";
          background = "${base}";
          text = "${text}";
          indicator = "${rosewater}";
          childBorder = "${overlay0}";
        };
        unfocused = {
          border = "${overlay0}";
          background = "${base}";
          text = "${text}";
          indicator = "${rosewater}";
          childBorder = "${overlay0}";
        };
        urgent = {
          border = "${peach}";
          background = "${base}";
          text = "${peach}";
          indicator = "${overlay0}";
          childBorder = "${peach}";
        };
        placeholder = {
          border = "${overlay0}";
          background = "${base}";
          text = "${text}";
          indicator = "${overlay0}";
          childBorder = "${overlay0}";
        };
        background = "${base}";
      });

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
          colors = {
            background         = "${base}";
            focusedBackground         = "${base}";
            statusline         = "${text}";
            separator = "${peach}";
            focusedStatusline = "${text}";
            focusedSeparator  = "${base}";
            activeWorkspace   = {border = "${surface0}"; background = "${surface1}"; text = "${blue}";};
            focusedWorkspace  = {border = "${surface0}"; background = "${surface1}"; text = "${green}";};
            inactiveWorkspace = {border = "${surface0}"; background = "${base}"; text = "${surface1}";};
            urgentWorkspace   = {border = "${red}"; background = "${peach}"; text = "${surface0}";};
            bindingMode       = {border = "${surface0}"; background = "${surface1}"; text = "${blue}";};
          };
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
        }
      ];
    };
  };
}
