_: {
  myConfig.hosts.hedwig = {
    isNixOs = true;
    username = "kdfrench";
    hasBattery = true;
    hasNvidiaGpu = false;
    isPersonal = true;
    nixosModules = [ ./_nixos/hedwig/default.nix ];
    hmModules = [
      ./_hm/home-base.nix
      ./_hm/i3.nix
      ./_hm/i3status-rust.nix
      ./_hm/zoxide.nix
      ./_hm/zsh.nix
      ./_hm/bash.nix
      ./_hm/starship.nix
      ./_hm/helix.nix
      ./_hm/git.nix
      ./_hm/gh.nix
      ./_hm/direnv.nix
      ./_hm/terminator.nix
    ];
  };
}
