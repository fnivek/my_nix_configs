{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    i3_scripts.url = "github:fnivek/i3_scripts";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, i3_scripts, ... }:
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
            home-manager.users.kdfrench = {
              imports = [
                ./home.nix
              ];
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = { inherit unstable; inherit inputs; };
          }
        ];
      };
    };
  };
}

