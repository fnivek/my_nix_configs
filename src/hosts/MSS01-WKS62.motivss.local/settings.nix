_: {
  imports = [ ../host-settings.nix ];
  config = {
    hostSettings = {
      hasBattery = false;
      isPersonal = false;
    };
  };
}
