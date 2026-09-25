{pkgs, ...}: {
  imports = [
    ./programs/git.nix
    ./programs/jujutsu.nix
    ./programs/ghostty.nix
    ./programs/gram.nix
    ./programs/niri.nix
    ./programs/noctalia.nix
  ];

  home.stateVersion = "23.11";

  gtk.enable = true;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  services.ssh-agent.enable = true;
}
