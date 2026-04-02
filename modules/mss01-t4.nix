_: {
  myConfig.hosts."kevinfrench@MSS01-T4" = {
    isNixOs = false;
    username = "kevinfrench";
    hasBattery = true;
    hasNvidiaGpu = true;
    isPersonal = false;
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
      {
        xsession.windowManager.i3.extraConfig = ''
          exec xrandr --setprovideroutputsource modesetting NVIDIA-0
          exec xrandr --auto
        '';
      }
    ];
  };
}
