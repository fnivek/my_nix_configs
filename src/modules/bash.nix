_: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      source "$(fzf-share)/key-bindings.bash"
      source "$(fzf-share)/completion.bash"
    '';

    # set some aliases
    shellAliases = {
      ls = "eza";
    };
  };
}
