{pkgs, ...}: {
  imports = [
    ./programs/git.nix
    ./programs/jujutsu.nix
    ./programs/ghostty.nix
    ./programs/gram.nix
  ];

  home.stateVersion = "23.11";

  services.ssh-agent.enable = true;
}
