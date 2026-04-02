{ lib, inputs, ... }:
{
  options.myConfig = {
    unstablePkgs = lib.mkOption {
      type = lib.types.unspecified;
      description = "nixpkgs-unstable package set";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            isNixOs = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            username = lib.mkOption {
              type = lib.types.str;
              default = "kdfrench";
            };
            hasBattery = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            hasNvidiaGpu = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            isPersonal = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
            nixosModules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
              default = [ ];
            };
            hmModules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
              default = [ ];
            };
          };
        }
      );
      default = { };
    };
  };

  config.myConfig.unstablePkgs = lib.mkDefault (
    import inputs.nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    }
  );
}
