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
    };
  };
in
{
  options = {
    hostSettings = lib.mkOption { type = hostSettingsType; };
  };
}
