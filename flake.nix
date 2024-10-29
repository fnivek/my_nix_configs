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
    let
      mkHost =
        hostname:
        let
          system = "x86_64-linux";
        in
        {
          name = hostname;
          value = nixpkgs.lib.nixosSystem {
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
                    imports = [
                      ./src/hosts/${hostname}/settings.nix
                      ./src/modules/home.nix
                    ];
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
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        builtins.map mkHost [
          "hagrid"
          "luna"
          "hedwig"
        ]
      );
    };
}
