{
  pkgs,
  programs,
  ...
}: {
  imports = [
    ./fish.nix
  ];
  environment.systemPackages = with pkgs; [
    fish
    git
    bat
    htop
    wget
    whois
  ];
}
