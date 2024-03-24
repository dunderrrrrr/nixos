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

  services.openssh.enable = true;
  services.tailscale.enable = true;

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
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+SY+kqLyZDhwcUgS8E+B1jqvKJBI4YcSjehxqJ45AkgqRw/lgTAWhEHzjN/SN0DYt04aSr6flwe2BSAr96MSKJ+QN4RhqjyQbcitaw04Gc5/A09acjsY1a9Hqf3ofmK2OfjacbvN2XaHBuyMixI3Z8t2pm615z+S5mBVxQJHdnCuRF+QH9gZKBPKHkzdIqTBGL+XBCXJLTXCdR8F9yKyIYUTgJdxUhiHpxC98oI38ITjDIyBCmt3WNGXHeDtai0PqMckYcb9xKsM9qXE/1CCrcaBk4pw3yOz4wW3xCHNHKUBoBa9w5E7cTxv5ADQdMfgTQFz2eHe8I0uVwSxR368k9IBPkzqSjEhVIMHEsLS8GyN/oY5UKf1OowmYk+0dJscsDLJL6TMLISIzF5sxp6QufOWXwdMzIkpxIXzTNLjPCvxnQtb7Mc2YbYeBPZV0A/pitITWzfxGulK7SLQ4RCwMSm4Yi+2Pc96dzLggwUZSZuNXqm/bEuaIPcU+t41eM2E="];
  };
  users.users.andreas = {
    isNormalUser = true;
    home = "/home/andreas";
    description = "andreas";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9IToYPBU0BXbr4+ECrzqL0J4+2HzS+x6BC/Ej5zmfjSfXzVBW3YQI5KjHFCsx3vmO+b6oo07NHg1Xgt6MnSaVn/XS48Ny2QPyecZ17YYRmM9du76GwGARKRtApQKzLh3isk7eNl0i+Z8gRX1ZyeAkydFPN/mQ4qGF0b5qu0OicU7XkmLt4EsoJg4y7QfeLb14Ce3eHAcldeu+gzhkT2AnZh9REqRQdjaVcQquq3+jrCaSpR6qNhCsl5ONOlQ6C+IUcdrC7AO4T+tmxHnd9We7CNe6+GZFp90vnhiYYZSZjfDULB2V/Y76ojueQW2CwDqcCjX0tAr4wYGLlZ/g190N"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1QxVMwB7DwjCq0lex5Ge++vD1AEairc9tg9ciflGFI"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIARRkX6xdDVF4nOAVEiN0/FIm8eC8XVKnQM6IxSNgssUAAAABHNzaDo="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    tailscale
    direnv
    bat
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
