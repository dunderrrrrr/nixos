{pkgs, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "emil@personalkollen.se";
        name = "Emil Björkroth";
      };
      ui = {
        default-command = "log"; # Allow running `jj` to see the log without a warning
        conflict-marker-style = "git";
        merge-editor = "vscode";
        pager = "less -FRX";
      };
      template-aliases.default_commit_description = ''
        "JJ: If applied, this commit will...

        JJ: Explain why this change is being made

        JJ: Provide links to any relevant tickets, articles or other resources

        "
      '';
    };
  };
}
