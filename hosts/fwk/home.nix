{pkgs, ...}: {
  imports = [
    ./programs/vscode.nix
    ./programs/git.nix
    ./programs/jujutsu.nix
    ./programs/zed.nix
    ./programs/ghostty.nix
  ];

  home.stateVersion = "23.11";

  services.ssh-agent.enable = true;
}
