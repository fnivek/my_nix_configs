{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };
    # Privileged access management (PAM) shim enables using PAMs on non-nixos systems.
    # i3lock, swaylock, etc all need access to standard PAMs but nix builds them to use nixos PAM.
    # See https://github.com/nix-community/home-manager/issues/7027 for details.
    pam-shim = {
      url = "github:Cu3PO42/pam_shim/next";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      i3_scripts,
      nix-colors,
      pam-shim,
      ...
    }:
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

      # NixOS systems.
      mkHost = hostname: {
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
                  inherit pkgs-unstable;
                  username = "kdfrench";
                  inherit nix-colors;
                  inherit pam-shim;
                  isNixOs = true;
                };
              };
            }
          ];
        };
      };
      mkHome =
        { hostname, username }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./src/hosts/${hostname}/settings.nix
            ./src/modules/home.nix
            {
              home.username = "${username}";
              home.homeDirectory = "/home/${username}";
            }
          ];

          extraSpecialArgs = {
            inherit inputs;
            inherit pkgs-unstable;
            inherit username;
            inherit nix-colors;
            inherit pam-shim;
            isNixOs = false;
          };
        };
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        builtins.map mkHost [
          "hagrid"
          "hedwig"
        ]
      );
      homeConfigurations = {
        "kevinfrench@MSS01-T4" = mkHome {
          hostname = "MSS01-T4";
          username = "kevinfrench";
        };
        "kdfrench@MSS01-WKS62.motivss.local" = mkHome {
          hostname = "MSS01-WKS62.motivss.local";
          username = "kdfrench";
        };
      };
    };
}
