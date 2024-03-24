# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  networking.networkmanager.enable = true;
  networking.hostName = "nixos-pelme"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "10.3.3.10";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "10.3.3.1";
  networking.nameservers = ["1.1.1.1"];

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "";
  };

  console.keyMap = "sv-latin1";

  users.users.emil = {
    isNormalUser = true;
    description = "emil";
    shell = pkgs.fish;
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    htop
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
