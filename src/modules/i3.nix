{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  # All packages used by i3 config file and there invocations.
  pkg_tools = rec {
    # Packages for i3 config and user space.
    user_pkgs = with pkgs; {
      inherit xss-lock;
      lock = config.lib.pamShim.replacePam i3lock;
      bar_menu = dmenu;
      clipboard = xclip;
      screenshot = maim;
      font = nerd-fonts.zed-mono;
    };
    lock_cmd = "${lib.getExe' user_pkgs.lock "i3lock"} -c 222222";
    auto_lock_cmd = "${lib.getExe' user_pkgs.xss-lock "xss-lock"} --transfer-sleep-lock -- ${lock_cmd}";
    # lock_cmd = "i3lock -c 222222";
    bar_menu_cmd = "${lib.getExe' user_pkgs.bar_menu "dmenu_run"}";
    screenshot_cmd = "${lib.getExe' user_pkgs.screenshot "maim"} -s | ${lib.getExe' user_pkgs.clipboard "xclip"} -selection clipboard -t image/png";
    font = {
      name = "ZedMono Nerd Font";
      style = "ExtraBold";
      size = 10;
    };
  };
  mod = "Mod4";
  dirs = [
    {
      key = "j";
      dir = "down";
    }
    {
      key = "k";
      dir = "up";
    }
    {
      key = "h";
      dir = "left";
    }
    {
      key = "l";
      dir = "right";
    }
    {
      key = "Down";
      dir = "down";
    }
    {
      key = "Up";
      dir = "up";
    }
    {
      key = "Left";
      dir = "left";
    }
    {
      key = "Right";
      dir = "right";
    }
  ];
  # Colors (https://github.com/catppuccin/i3/blob/main/themes/catppuccin-mocha)
  rosewater = "#f5e0dc";
  flamingo = "#f2cdcd";
  pink = "#f5c2e7";
  mauve = "#cba6f7";
  red = "#f38ba8";
  maroon = "#eba0ac";
  peach = "#fab387";
  yellow = "#f9e2af";
  green = "#a6e3a1";
  teal = "#94e2d5";
  sky = "#89dceb";
  sapphire = "#74c7ec";
  blue = "#89b4fa";
  lavender = "#b4befe";
  text = "#cdd6f4";
  subtext1 = "#bac2de";
  subtext0 = "#a6adc8";
  overlay2 = "#9399b2";
  overlay1 = "#7f849c";
  overlay0 = "#6c7086";
  surface2 = "#585b70";
  surface1 = "#45475a";
  surface0 = "#313244";
  base = "#1e1e2e";
  mantle = "#181825";
  crust = "#11111b";
  # Scripts
  # TODO(Kevin): Is this really the best way to get this?
  workspace_script = inputs.i3_scripts.packages.x86_64-linux.default.out + "/bin/workspace";
  focus_next = inputs.i3_scripts.packages.x86_64-linux.default.out + "/bin/focus_next";
  focus_last = inputs.i3_scripts.packages.x86_64-linux.default.out + "/bin/focus_last";
  focus_window = inputs.i3_scripts.packages.x86_64-linux.default.out + "/bin/focus_window";
  focus_history_server_launch =
    inputs.i3_scripts.packages.x86_64-linux.focus_history_server_launch.out
    + "/bin/focus_history_server_launch";
  toggle_touchpad =
    inputs.i3_scripts.packages.x86_64-linux.toggleTouchpad.out + "/bin/toggle-touchpad";
  display_script =
    inputs.i3_scripts.packages.x86_64-linux.toggleDisplays.out + "/bin/toggle-displays";
  # Modes
  mode_scratchpad = "Tasks (-) term (Return) comms (c) music (m) teams (t) notes (n)";
  mode_system = "System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown";
  mode_display = "Display (t) toggle (a) all (c) clones (i) internal (e) external";
in
{
  # Install all packages used by i3 config in the user path.
  # This ensures that any configuration files that home-manager manages get generated.
  home.packages = builtins.attrValues pkg_tools.user_pkgs;

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = {
        # Set colors
        colors = lib.mkDefault {
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
        };

        modifier = mod;

        fonts = {
          names = [
            "${pkg_tools.font.name}"
          ];
          style = "${pkg_tools.font.style}";
          size = "${toString pkg_tools.font.size}";
        };

        keybindings = lib.mkDefault (
          {
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
            "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

            "${mod}+r" = "mode resize";

            "${mod}+Return" = "exec terminator";

            # vim style workspace history
            "${mod}+i" = "exec ${focus_next}";
            "${mod}+o" = "exec ${focus_last}";
            # Jump to any window
            "${mod}+p" = "exec ${focus_window}";

            # Touchpad controls
            "XF86TouchpadToggle" = "exec ${toggle_touchpad}";
            "${mod}+t" = "exec --no-startup-id ${toggle_touchpad}";

            # Move workspace to left monitor (loops)
            "${mod}+m" = "move workspace to output left";

            # Audio controls
            "XF86AudioRaiseVolume" = "exec amixer -q -D pipewire sset Master 5%+";
            "XF86AudioLowerVolume" = "exec amixer -q -D pipewire sset Master 5%-";
            "XF86AudioMute" = "exec amixer -q -D pipewire sset Master toggle";

            "Print" = "exec --no-startup-id shutter";
          }
          // (builtins.listToAttrs (
            map (dir: {
              name = "${mod}+${dir.key}";
              value = "focus ${dir.dir}";
            }) dirs
          ))
          // (builtins.listToAttrs (
            map (dir: {
              name = "${mod}+Shift+${dir.key}";
              value = "move ${dir.dir}";
            }) dirs
          ))
          // {
            "${mod}+d" = "exec ${pkg_tools.bar_menu_cmd}";
            "${mod}+x" = "exec sh -c '${pkg_tools.screenshot_cmd}'";
            "${mod}+Shift+x" = "exec sh -c '${pkg_tools.lock_cmd}'";
          }
        );

        window.commands = [
          {
            criteria = {
              title = "Todoist";
            };
            command = "move workspace 1:1:Com";
          }
          {
            criteria = {
              title = "Gmail";
            };
            command = "move workspace 2:2:Com";
          }
          {
            criteria = {
              title = "Calendar";
            };
            command = "move workspace 3:3:Com";
          }
          {
            criteria = {
              title = "Music";
            };
            command = "move workspace 4:4:Com";
          }
        ];

        bars = [
          {
            colors = {
              background = "${base}";
              focusedBackground = "${base}";
              statusline = "${text}";
              separator = "${peach}";
              focusedStatusline = "${text}";
              focusedSeparator = "${base}";
              activeWorkspace = {
                border = "${surface0}";
                background = "${surface1}";
                text = "${green}";
              };
              focusedWorkspace = {
                border = "${surface0}";
                background = "${surface1}";
                text = "${blue}";
              };
              inactiveWorkspace = {
                border = "${surface0}";
                background = "${base}";
                text = "${surface1}";
              };
              urgentWorkspace = {
                border = "${red}";
                background = "${peach}";
                text = "${surface0}";
              };
              bindingMode = {
                border = "${surface0}";
                background = "${surface1}";
                text = "${green}";
              };
            };
            position = "top";
            statusCommand = "i3status-rs config-top.toml";
            trayOutput = "primary";
            workspaceNumbers = false;
            fonts = {
              names = [
                "${pkg_tools.font.name}"
              ];
              style = "${pkg_tools.font.style}";
              size = "${toString pkg_tools.font.size}";
            };
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
            bindsym l exec --no-startup-id sh -c '${pkg_tools.lock_cmd}', mode "default";
            bindsym e exec --no-startup-id i3-msg exit, mode "default"
            bindsym s exec --no-startup-id sh -c '${pkg_tools.lock_cmd} && systemctl suspend', mode "default"
            bindsym h exec --no-startup-id sh -c '${pkg_tools.lock_cmd} && systemctl hibernate', mode "default"
            bindsym r exec --no-startup-id systemctl reboot, mode "default"
            bindsym Shift+s exec --no-startup-id systemctl poweroff, mode "default"

            # Back to normal: Enter or Escape
            bindsym Return mode "default"
            bindsym Escape mode "default"
        }
        bindsym ${mod}+z mode "${mode_system}"

        # Toggle display mode
        mode "${mode_display}" {
            bindsym t exec --no-startup-id "${display_script} toggle", mode default
            bindsym a exec --no-startup-id "${display_script} all", mode default
            bindsym c exec --no-startup-id "${display_script} clones", mode default
            bindsym i exec --no-startup-id "${display_script} internal", mode default
            bindsym e exec --no-startup-id "${display_script} external", mode default

            # Back to normal: Enter or Escape
            bindsym Return mode "default"
            bindsym Escape mode "default"
        }
        bindsym ${mod}+Shift+P mode "${mode_display}"

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

        exec_always --no-startup-id "${focus_history_server_launch}"
        exec --no-startup-id "${toggle_touchpad}"

        # Auto lock
        exec --no-startup-id xset s on
        exec --no-startup-id xset s 900 600
        exec --no-startup-id ${pkg_tools.auto_lock_cmd}
      '';
    };
  };
}
