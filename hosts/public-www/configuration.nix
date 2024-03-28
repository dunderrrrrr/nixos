{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "10.10.10.11";
      prefixLength = 24;
    }
  ];
  networking.firewall.interfaces."ens18".allowedTCPPorts = [8000];

  networking.defaultGateway = "10.10.10.1";
  networking.nameservers = ["1.1.1.1"];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["root" "emil"];

  networking.hostName = "public-www";

  networking.networkmanager.enable = true;

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

  services.xserver.xkb.layout = "se";
  services.xserver.xkb.variant = "";

  console.keyMap = "sv-latin1";

  users.users.emil = {
    isNormalUser = true;
    description = "emil";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
  ];
  system.stateVersion = "23.11"; # Did you read the comment?
}
