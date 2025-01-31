{pkgs, ...}: {
  imports = [
    ./programs/vscode.nix
    ./programs/git.nix
    ./programs/jujutsu.nix
    ./programs/firefox.nix
    ./programs/kitty.nix
  ];

  home.stateVersion = "23.11";

  programs.direnv.enable = true;
}
