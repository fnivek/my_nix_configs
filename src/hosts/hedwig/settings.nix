_: {
  imports = [ ../host-settings.nix ];
  config = {
    hostSettings = {
      hasBattery = true;
    };
  };
}
