{ config, lib, pkgs, inputs, ... }:
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
  # Scripts
  # TODO(Kevin): Is this really the best way to get this?
  workspace_script = inputs.i3_scripts.packages.x86_64-linux.default.out + "/bin/workspace";
  # Modes
  mode_scratchpad = "Tasks (-) term (Return) comms (c) music (m) teams (t) notes (n)";
  mode_system = "System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown";
  # Lock
  lock_cmd = "${pkgs.i3lock}/bin/i3lock -c 222222";
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

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+Shift+e" =
          "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

        "${mod}+r" = "mode resize";

        "${mod}+Return" = "exec terminator";
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
        "${mod}+Shift+x" = "exec sh -c '${lock_cmd}'";
      });

      window.commands = [
        {
          criteria = { title = "Todoist"; };
          command = "move workspace 1:1:Com";
        }
        {
          criteria = { title = "Gmail"; };
          command = "move workspace 2:2:Com";
        }
        {
          criteria = { title = "Calendar"; };
          command = "move workspace 3:3:Com";
        }
        {
          criteria = { title = "Music"; };
          command = "move workspace 4:4:Com";
        }
      ];

      bars = [
        {
          colors = {
            background         = "${base}";
            focusedBackground         = "${base}";
            statusline         = "${text}";
            separator = "${peach}";
            focusedStatusline = "${text}";
            focusedSeparator  = "${base}";
            activeWorkspace   = {border = "${surface0}"; background = "${surface1}"; text = "${green}";};
            focusedWorkspace  = {border = "${surface0}"; background = "${surface1}"; text = "${blue}";};
            inactiveWorkspace = {border = "${surface0}"; background = "${base}"; text = "${surface1}";};
            urgentWorkspace   = {border = "${red}"; background = "${peach}"; text = "${surface0}";};
            bindingMode       = {border = "${surface0}"; background = "${surface1}"; text = "${green}";};
          };
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
          trayOutput = "primary";
          workspaceNumbers = false;
        }
      ];
    };
    extraConfig = ''
      mode "${mode_scratchpad}" {
        bindsym minus exec --no-startup-id i3-msg 'workspace 1:1:Com', mode default
        bindsym c exec --no-startup-id i3-msg 'workspace 2:2:Com', mode default
        bindsym t exec --no-startup-id i3-msg 'workspace 3:3:Com', mode default
        bindsym m exec --no-startup-id i3-msg 'workspace 4:4:Com', mode default
        bindsym Return [instance="terminator"] scratchpad show, mode default
        bindsym n [instance="obsidian"] scratchpad show, mode default
        bindsym Escape mode "default"
      }
      bindsym ${mod}+minus mode "${mode_scratchpad}"

      mode "${mode_system}" {
          bindsym l exec --no-startup-id sh -c '${lock_cmd}', mode "default";
          bindsym e exec --no-startup-id i3-msg exit, mode "default"
          bindsym s exec --no-startup-id sh -c '${lock_cmd} && systemctl suspend', mode "default"
          bindsym h exec --no-startup-id sh -c '${lock_cmd} && systemctl hibernate', mode "default"
          bindsym r exec --no-startup-id systemctl reboot, mode "default"
          bindsym Shift+s exec --no-startup-id systemctl poweroff, mode "default"

          # Back to normal: Enter or Escape
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym ${mod}+z mode "${mode_system}"

      bindsym ${mod}+n [instance="obsidian"] scratchpad show
      bindsym ${mod}+1 exec --no-startup-id "${workspace_script} 1"
      bindsym ${mod}+2 exec --no-startup-id "${workspace_script} 2"
      bindsym ${mod}+3 exec --no-startup-id "${workspace_script} 3"
      bindsym ${mod}+4 exec --no-startup-id "${workspace_script} 4"
      bindsym ${mod}+5 exec --no-startup-id "${workspace_script} 5"
      bindsym ${mod}+6 exec --no-startup-id "${workspace_script} 6"
      bindsym ${mod}+7 exec --no-startup-id "${workspace_script} 7"
      bindsym ${mod}+8 exec --no-startup-id "${workspace_script} 8"
      bindsym ${mod}+9 exec --no-startup-id "${workspace_script} 9"
      bindsym ${mod}+0 exec --no-startup-id "${workspace_script} 10"
      bindsym Control+Mod1+Left exec --no-startup-id "${workspace_script} prev"
      bindsym Control+Mod1+Right exec --no-startup-id "${workspace_script} next"
      bindsym Control+Mod1+Shift+Left exec --no-startup-id "${workspace_script} -m -f prev"
      bindsym Control+Mod1+Shift+Right exec --no-startup-id "${workspace_script} -m -f next"
      bindsym Control+Mod1+Up exec --no-startup-id "${workspace_script} up"
      bindsym Control+Mod1+Down exec --no-startup-id "${workspace_script} down"
      bindsym Control+Mod1+Shift+Up exec --no-startup-id "${workspace_script} -m -f up"
      bindsym Control+Mod1+Shift+Down exec --no-startup-id "${workspace_script} -m -f down"
      bindsym Control+Mod1+h exec --no-startup-id "${workspace_script} prev"
      bindsym Control+Mod1+l exec --no-startup-id "${workspace_script} next"
      bindsym Control+Mod1+Shift+h exec --no-startup-id "${workspace_script} -m -f prev"
      bindsym Control+Mod1+Shift+l exec --no-startup-id "${workspace_script} -m -f next"
      bindsym Control+Mod1+k exec --no-startup-id "${workspace_script} up"
      bindsym Control+Mod1+j exec --no-startup-id "${workspace_script} down"
      bindsym Control+Mod1+Shift+k exec --no-startup-id "${workspace_script} -m -f up"
      bindsym Control+Mod1+Shift+j exec --no-startup-id "${workspace_script} -m -f down"

      bindsym ${mod}+Shift+1 exec --no-startup-id "${workspace_script} -m 1"
      bindsym ${mod}+Shift+2 exec --no-startup-id "${workspace_script} -m 2"
      bindsym ${mod}+Shift+3 exec --no-startup-id "${workspace_script} -m 3"
      bindsym ${mod}+Shift+4 exec --no-startup-id "${workspace_script} -m 4"
      bindsym ${mod}+Shift+5 exec --no-startup-id "${workspace_script} -m 5"
      bindsym ${mod}+Shift+6 exec --no-startup-id "${workspace_script} -m 6"
      bindsym ${mod}+Shift+7 exec --no-startup-id "${workspace_script} -m 7"
      bindsym ${mod}+Shift+8 exec --no-startup-id "${workspace_script} -m 8"
      bindsym ${mod}+Shift+9 exec --no-startup-id "${workspace_script} -m 9"
      bindsym ${mod}+Shift+0 exec --no-startup-id "${workspace_script} -m 10"

      gaps inner 5
      smart_gaps on
      '';
  };
}
