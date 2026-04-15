{pkgs, ...}: {
  programs.git = {
    enable = true;

    signing = {
      key = "F8782F0E39D90508";
      signByDefault = true;
      format = "openpgp";
    };

    settings = {
      user.name = "dunderrrrrr";
      user.email = "emil.bjorkroth@gmail.com";

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
