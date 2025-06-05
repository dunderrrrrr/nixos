{
  pkgs,
  programs,
  ...
}: {
  imports = [
    ./programs/fish.nix
    ./programs/nano.nix
  ];
  environment.systemPackages = with pkgs; [
    fish
    git
    bat
    htop
    wget
    whois
    dig
    netcat
    duf
    nanorc
    fd
    ripgrep
  ];
}
