{pkgs, ...}: {
  imports = [
    ./programs/vscode.nix
    ./programs/git.nix
    ./programs/jujutsu.nix
  ];

  home.stateVersion = "23.11";

  services.ssh-agent.enable = true;
}
