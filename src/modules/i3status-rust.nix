{ config, lib, ... }:
{
  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        theme = "ctp-mocha";
        blocks =
          [
            # { block = "docker"; }
            { block = "nvidia_gpu"; }
            { block = "cpu"; }
            {
              block = "memory";
              format = " $icon $mem_total_used_percents.eng(w:2) ";
              format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
            }
            {
              block = "sound";
              click = [
                {
                  button = "left";
                  cmd = "pavucontrol";
                }
              ];
            }
          ]
          ++ lib.optional config.hostSettings.hasBattery {
            block = "battery";
          }
          ++ [
            {
              block = "time";
              interval = 5;
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            }
          ];
      };
    };
  };
}
