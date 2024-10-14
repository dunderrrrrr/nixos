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
      gg = "git push gerrit HEAD:refs/for/main";

      # https://github.com/alacritty/alacritty/issues/1208
      # https://www.reddit.com/r/KittyTerminal/comments/13ephdh/xtermkitty_ssh_woes_i_know_about_the_kitten_but/
      ssh = "TERM=xterm-256color ssh";
    };
  };
}
