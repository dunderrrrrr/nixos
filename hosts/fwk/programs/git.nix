{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "dunderrrrrr";
    userEmail = "emil.bjorkroth@gmail.com";

    extraConfig = {
      push.default = "current";
      pull.rebase = true;
      commit.template = "${./templates/git_commit.txt}";

      # delta git diff
      core.pager = "${pkgs.delta}/bin/delta";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      delta.navigate = true;
      delta.light = false;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
