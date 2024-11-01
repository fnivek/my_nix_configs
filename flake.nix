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

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-23,
      home-manager,
      i3_scripts,
      ...
    }:
    {
      nixosConfigurations = {
        hagrid =
          let
            system = "x86_64-linux";
            hostname = "hagrid";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs;
            };
            modules = [
              # System level
              ./src/hosts/${hostname}

              # User level
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.kdfrench = {
                    imports = [ ./src/modules/home.nix ];
                  };
                  # Optionally, use home-manager.extraSpecialArgs to pass
                  # arguments to home.nix
                  extraSpecialArgs = {
                    inherit inputs;
                  };
                };
              }
            ];
          };
        luna =
          let
            system = "x86_64-linux";
            hostname = "luna";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs;
            };
            modules = [
              # System level
              ./src/hosts/${hostname}

              # User level
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.kdfrench = {
                    imports = [ ./src/modules/home.nix ];
                  };

                  # Optionally, use home-manager.extraSpecialArgs to pass
                  # arguments to home.nix
                  extraSpecialArgs = {
                    inherit inputs;
                  };
                };
              }
            ];
          };
      };
    };
}
