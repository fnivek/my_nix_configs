{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/*";
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
      nixpkgs-unstable,
      determinate,
      home-manager,
      i3_scripts,
      ...
    }:
    let
      mkHost =
        hostname:
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          name = hostname;
          value = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs;
            };
            modules = [
              # Load Determinate
              determinate.nixosModules.default
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
                    inherit pkgs-unstable;
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
