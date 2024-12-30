{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nixos-public";

  networking.firewall.allowedTCPPorts = [22 80 443];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  time.timeZone = "Europe/Stockholm";

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["root" "emil"];

  console.keyMap = "sv-latin1";

  users.users.emil = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "emil";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+SY+kqLyZDhwcUgS8E+B1jqvKJBI4YcSjehxqJ45AkgqRw/lgTAWhEHzjN/SN0DYt04aSr6flwe2BSAr96MSKJ+QN4RhqjyQbcitaw04Gc5/A09acjsY1a9Hqf3ofmK2OfjacbvN2XaHBuyMixI3Z8t2pm615z+S5mBVxQJHdnCuRF+QH9gZKBPKHkzdIqTBGL+XBCXJLTXCdR8F9yKyIYUTgJdxUhiHpxC98oI38ITjDIyBCmt3WNGXHeDtai0PqMckYcb9xKsM9qXE/1CCrcaBk4pw3yOz4wW3xCHNHKUBoBa9w5E7cTxv5ADQdMfgTQFz2eHe8I0uVwSxR368k9IBPkzqSjEhVIMHEsLS8GyN/oY5UKf1OowmYk+0dJscsDLJL6TMLISIzF5sxp6QufOWXwdMzIkpxIXzTNLjPCvxnQtb7Mc2YbYeBPZV0A/pitITWzfxGulK7SLQ4RCwMSm4Yi+2Pc96dzLggwUZSZuNXqm/bEuaIPcU+t41eM2E="];
  };

  environment.systemPackages = with pkgs; [
    git
    caddy
    devenv
  ];

  systemd.services.mat-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve mat.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = "/home/emil/projects/mat.dunderrrrrr.se";
      ExecStart = "/home/emil/projects/mat.dunderrrrrr.se/.venv/bin/gunicorn -w 4 dash:app";
    };
    environment = {
      PATH = lib.mkForce "/home/emil/projects/mat.dunderrrrrr.se/.venv/bin";
    };
    wantedBy = ["multi-user.target"];
  };

  services.caddy = {
    enable = true;

    virtualHosts = {
      "mat.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8000
          file_server
        '';
      };
    };
  };

  system.stateVersion = "24.05";
}
