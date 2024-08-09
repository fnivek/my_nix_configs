{...} @ inputs :
{
  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        theme = "ctp-mocha";
      };
    };
  };
}
