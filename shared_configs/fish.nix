{
  pkgs,
  programs,
  ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = "direnv hook fish | source";
    shellAbbrs = {
      gpf = "git push --force-with-lease";
      gca = "git commit --amend --no-edit";
      gr = "git rebase -i origin/main";
      gpr = "git pull --rebase origin main";
      gs = "git switch";
      py = "django-admin shell_plus --quiet-load";
      ax = "aws-vault exec pk --";
      cat = "bat";
      nr = "sudo nixos-rebuild switch --flake .#";
      nc = "sudo nix-collect-garbage --delete-older-than 15d";
      ns = "nix-shell --command fish";
    };
  };
}
