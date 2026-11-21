_: {
  imports = [ ../host-settings.nix ];
  hostSettings = {
    hasBattery = false;
    # Hagrid hosts the assistant VM, so it must stay awake.
    autoSuspend = false;
  };
}
