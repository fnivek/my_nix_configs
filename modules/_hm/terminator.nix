{
  config,
  lib,
  pkgs,
  ...
}:
let
  p = config.colorScheme.palette;
  hex = c: "#${c}";
  paletteString = lib.concatStringsSep ":" (
    map hex [
      # normal
      p.base00
      p.base08
      p.base0B
      p.base0A
      p.base0D
      p.base0E
      p.base0C
      p.base05

      # bright
      p.base03
      p.base08
      p.base0B
      p.base0A
      p.base0D
      p.base0E
      p.base0C
      p.base07
    ]
  );
  font = {
    name = "ZedMono Nerd Font Ultra-Bold Expanded";
    size = 10;
    package = pkgs.nerd-fonts.zed-mono;
  };
in
{
  home.packages = [
    font.package
  ];

  programs.terminator = {
    enable = true;
    config = {
      profiles.default = {
        use_system_font = false;
        font = "${font.name} ${toString font.size}";
        background_color = hex p.base00;
        foreground_color = hex p.base05;
        cursor_color = hex p.base06;
        # This is the palette using the full non-16 bit version.
        # palette = "#45475a:#f38ba8:#a6e3a1:#f9e2af:#89b4fa:#f5c2e7:#94e2d5:#bac2de:#585b70:#f38ba8:#a6e3a1:#f9e2af:#89b4fa:#f5c2e7:#94e2d5:#a6adc8"
        palette = paletteString;
        background_image = "None";
      };
    };
  };
}
