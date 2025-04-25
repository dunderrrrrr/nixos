{
  pkgs,
  programs,
  ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      direnv hook fish | source
    '';
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
      cg = "sudo nix-collect-garbage --delete-older-than 15d";
      ns = "nix-shell --command fish";
      gg = "git push origin HEAD:refs/for/main -o t=(git branch --show-current)";
      pb = "pkbuild";
      jja = "jj abandon ";
      jjw = "watch -n1 --color jj --ignore-working-copy log --color=always";
      jjr = "git fetch && jj rebase -b 'all:mutable() & mine()' -d main@origin --skip-emptied";
      jjn = "jj new main@origin";
    };
  };
}
