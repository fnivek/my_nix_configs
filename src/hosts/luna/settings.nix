_: {
  imports = [ ../host-settings.nix ];
  config = {
    hostSettings = {
      hasBattery = true;
      isPersonal = false;
    };
    xsession.windowManager.i3.extraConfig = ''
      exec xrandr --setprovideroutputsource modesetting NVIDIA-0
      exec xrandr --auto
    '';
  };
}
