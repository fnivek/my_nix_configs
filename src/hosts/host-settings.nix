{ lib, ... }:
let
  hostSettingsType = lib.types.submodule {
    options = {
      hasBattery = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      hasNvidiaGpu = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      isPersonal = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      autoSuspend = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Suspend the machine after a long idle period.";
      };
    };
  };
in
{
  options = {
    hostSettings = lib.mkOption { type = hostSettingsType; };
  };
}
