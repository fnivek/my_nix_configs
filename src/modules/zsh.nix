{ config, pkgs, ... }@inputs:
{
  programs.zsh =
    let
      fzfKeybindings = ''
        if [ -n "''${commands[fzf-share]}" ]; then
          source "$(fzf-share)/key-bindings.zsh"
          source "$(fzf-share)/completion.zsh"
        fi
      '';
      historySearchKeybindings = ''
        bindkey '^p' history-search-backward
        bindkey '^n' history-search-forward
      '';
      # TODO(Kevin): See if we can get list colors to match eza.
      completionStyle = ''
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        # Disable menu we use fzf-tab
        zstyle ':completion:*' menu no
      '';
      fzfTab = ''
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
      '';
    in
    {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ls = "eza";
        update = "sudo nixos-rebuild switch";
        taskg = "task -g";
      };
      initExtra = fzfKeybindings + historySearchKeybindings + completionStyle + fzfTab;
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreSpace = true;
        ignoreAllDups = true;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      plugins = [
        {
          name = "fzf-tab";
          file = "fzf-tab.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "aloxaf";
            repo = "fzf-tab";
            rev = "master";
            sha256 = "sha256-4A7zpaO1rNPvS0rrmmxg56rJGpZHnw/g+x5FJd0EshI=";
          };
        }
      ];
    };
}
