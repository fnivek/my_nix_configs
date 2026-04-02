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
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
