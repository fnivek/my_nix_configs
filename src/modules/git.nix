_: {
  programs.git = {
    enable = true;
    userName = "Kevin French";
    userEmail = "fnivek@gmail.com";
    aliases = {
      la = "!git config -l | grep alias | cut -c 7-";

      lg = "!git lg1";
      lg1-all = "!git lg1 --all";
      lg2-all = "!git lg2 --all";
      lg3-all = "!git lg3 --all";

      lg1 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
      lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
      lg3 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'";

      last = "!git lg3-specific -1 HEAD --numstat";
    };
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "hx";
      core.autocrlf = "input";
    };
  };
}
