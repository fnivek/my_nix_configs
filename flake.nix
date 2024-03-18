{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, hy3, ... }:
  let
    system = "x86_64-linux";
    nixpkgsConfig = {
      inherit system;
      config.allowUnfree = true;
    };
    unstable = import nixpkgs-unstable nixpkgsConfig;
  in
  {
    nixosConfigurations = {
      hagrid = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kdfrench = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = { inherit unstable; inherit inputs; };
          }
        ];
      };
    };
  };
}

