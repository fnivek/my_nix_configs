{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-23.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    i3_scripts = {
      url = "github:fnivek/i3_scripts";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-23, home-manager, i3_scripts, ... }:
  let
    system = "x86_64-linux";
    nixpkgsConfig = {
      inherit system;
      config.allowUnfree = true;
    };
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
            home-manager.users.kdfrench = {
              imports = [
                ./home.nix
              ];
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}

