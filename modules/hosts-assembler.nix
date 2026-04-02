{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.myConfig;
  stablePkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  # Modules injected for every host regardless of feature opt-ins.
  # Replaces all extraSpecialArgs / specialArgs pass-through.
  mkCommonHmModules =
    hostCfg:
    [
      ./_hm/host-settings.nix
      inputs.nix-colors.homeManagerModules.default
      inputs.pam-shim.homeModules.default
      {
        _module.args = {
          inherit inputs;
          pkgs-unstable = cfg.unstablePkgs;
        };
        home.username = hostCfg.username;
        home.homeDirectory = "/home/${hostCfg.username}";
        hostSettings = {
          inherit (hostCfg) hasBattery hasNvidiaGpu isPersonal;
        };
        pamShim.enable = !hostCfg.isNixOs;
      }
    ]
    ++ hostCfg.hmModules;

  mkNixosSystem =
    _hostname: hostCfg:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = hostCfg.nixosModules ++ [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${hostCfg.username}.imports = mkCommonHmModules hostCfg;
          };
        }
      ];
    };

  mkHomeConfig =
    _name: hostCfg:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = stablePkgs;
      modules = mkCommonHmModules hostCfg;
    };

in
{
  flake.nixosConfigurations = lib.mapAttrs mkNixosSystem (
    lib.filterAttrs (_: h: h.isNixOs) cfg.hosts
  );

  flake.homeConfigurations = lib.mapAttrs mkHomeConfig (lib.filterAttrs (_: h: !h.isNixOs) cfg.hosts);
}
