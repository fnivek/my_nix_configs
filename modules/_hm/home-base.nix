{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  inputs,
  ...
}:
{
  # Dark mode.
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  # Light mode.
  # colorScheme = inputs.nix-colors.colorSchemes.catppuccin-latte;

  targets.genericLinux.enable = true;

  home = {
    stateVersion = "25.11";
    packages =
      with pkgs;
      [
        # Web
        google-chrome

        # Notes
        obsidian

        # archives
        zip
        xz
        unzip
        p7zip

        # utils
        ripgrep # recursively searches directories for a regex pattern
        jq # A lightweight and flexible command-line JSON processor
        yq-go # yaml processer https://github.com/mikefarah/yq
        eza # A modern replacement for 'ls'
        fzf # A command-line fuzzy finder
        arandr

        # networking tools
        socat # replacement of openbsd-netcat
        nmap # A utility for network discovery and security auditing

        # misc
        cowsay
        which
        tree
        gnused
        gnutar
        gawk
        zstd
        gnupg
        bat

        # nix related
        #
        # it provides the command `nom` works just like `nix`
        # with more details log output
        nix-output-monitor
        nixfmt-rfc-style

        # productivity
        hugo # static site generator
        glow # markdown previewer in terminal

        btop # replacement of htop/nmon
        iotop # io monitoring
        iftop # network monitoring

        # system call monitoring
        strace # system call monitoring
        ltrace # library call monitoring
        lsof # list open files

        # system tools
        sysstat
        lm_sensors # for `sensors` command
        ethtool
        pciutils # lspci
        usbutils # lsusb

        # Screen capture.
        shutter

        # Dev tools
        pkgs-unstable.devbox
        go-task

        # Fonts
        noto-fonts-color-emoji
        font-awesome
        nerd-fonts.ubuntu
      ]
      ++ lib.optional config.hostSettings.isPersonal pkgs.steam;
  };

  fonts.fontconfig.enable = true;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Services
  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
  };
}
