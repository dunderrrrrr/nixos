{
  config,
  lib,
  pkgs,
  ...
}: let
  hotelsProjectRoot = "/home/hotels/hotels";
  swarjeProjectRoot = "/home/swarje/swarje";
  wcwpProjectRoot = "/home/wcwp/wcwp";
  domanfluffProjectRoot = "/home/domanfluff/domanfluff";
in {
  imports = [
    ./caddy.nix
    ./hardware-configuration.nix
    ./users.nix
  ];

  nix.extraOptions = ''
    connect-timeout = 5
  '';

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";

  networking.hostName = "nixos-public";

  networking.firewall.allowedTCPPorts = [
    22228
    80
    443
  ];

  services.openssh = {
    enable = true;
    ports = [22228];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      data-root = "/mnt/docker";
    };
  };

  time.timeZone = "Europe/Stockholm";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "emil"
  ];

  console.keyMap = "sv-latin1";

  services.journald.extraConfig = ''
    SystemMaxUse=300M
    SystemMaxFileSize=40M
    MaxRetentionSec=4day
  '';

  environment.systemPackages = with pkgs; [
    jq
    git
    caddy
    goaccess
    devenv
    screen
    docker-compose
    direnv
  ];

  systemd.services.hotels-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve hotels.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "hotels";
      Group = "hotels";
      WorkingDirectory = hotelsProjectRoot;
      EnvironmentFile = "${hotelsProjectRoot}/.env";
      ExecStartPre = "${hotelsProjectRoot}/.venv/bin/python manage.py collectstatic --noinput";
      ExecStart = "${hotelsProjectRoot}/.venv/bin/gunicorn -w 4 --bind 127.0.0.1:8001 hotels.wsgi";
    };
    environment = {
      PATH = lib.mkForce "${hotelsProjectRoot}/.venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.swarje-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve swarje.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "swarje";
      Group = "swarje";
      WorkingDirectory = swarjeProjectRoot;
      ExecStart = "${swarjeProjectRoot}/.devenv/state/venv/bin/gunicorn -w 8 --bind 127.0.0.1:8002 run:app";
    };
    environment = {
      PATH = lib.mkForce "${swarjeProjectRoot}/.devenv/state/venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.wcwp = {
    enable = true;
    description = "Gunicorn instance to serve wcwp";
    after = ["network.target"];
    serviceConfig = {
      User = "wcwp";
      Group = "wcwp";
      WorkingDirectory = wcwpProjectRoot;
      ExecStart = "${wcwpProjectRoot}/.venv/bin/gunicorn -w 4 --bind 127.0.0.1:8009 run:app";
    };
    environment = {
      PATH = lib.mkForce "${wcwpProjectRoot}/.venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.domanfluff = {
    description = "Serve domanfluff";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "domanfluff";
      Group = "domanfluff";
      WorkingDirectory = domanfluffProjectRoot;
      ExecStart = "${domanfluffProjectRoot}/.venv/bin/gunicorn -w 4 --bind 127.0.0.1:8012 run:app";
    };
    environment = {
      PATH = lib.mkForce "${domanfluffProjectRoot}/.venv/bin/";
    };
  };

  system.stateVersion = "24.05";
}
