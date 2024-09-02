_: {
  imports = [ ../host-settings.nix ];
  config = {
    hostSettings = {
      hasBattery = true;
    };
    xsession.windowManager.i3.extraConfig = ''
      exec xrandr --setprovideroutputsource modesetting NVIDIA-0
      exec xrandr --auto
    '';
  };
}
