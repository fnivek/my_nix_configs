_: {
  # Packages that should be installed to the user profile.
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        rulers = [ 101 ];
      };
    };
  };
}
