{
  config,
  lib,
  pkgs,
  ...
}: let
  hotelsProjectRoot = "/home/emil/projects/hotels.dunderrrrrr.se/";
  swarjeProjectRoot = "/home/emil/projects/swarje.dunderrrrrr.se";
  deployProjectRoot = "/home/emil/projects/nixos-public-deployer";
  blocketapiProjectRoot = "/home/emil/projects/blocket-api.se";
  wcwpProjectRoot = "/home/emil/projects/wcwp";
in {
  imports = [
    ./caddy.nix
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

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

  virtualisation.docker.enable = true;

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

  users.users.emil = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "emil";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+SY+kqLyZDhwcUgS8E+B1jqvKJBI4YcSjehxqJ45AkgqRw/lgTAWhEHzjN/SN0DYt04aSr6flwe2BSAr96MSKJ+QN4RhqjyQbcitaw04Gc5/A09acjsY1a9Hqf3ofmK2OfjacbvN2XaHBuyMixI3Z8t2pm615z+S5mBVxQJHdnCuRF+QH9gZKBPKHkzdIqTBGL+XBCXJLTXCdR8F9yKyIYUTgJdxUhiHpxC98oI38ITjDIyBCmt3WNGXHeDtai0PqMckYcb9xKsM9qXE/1CCrcaBk4pw3yOz4wW3xCHNHKUBoBa9w5E7cTxv5ADQdMfgTQFz2eHe8I0uVwSxR368k9IBPkzqSjEhVIMHEsLS8GyN/oY5UKf1OowmYk+0dJscsDLJL6TMLISIzF5sxp6QufOWXwdMzIkpxIXzTNLjPCvxnQtb7Mc2YbYeBPZV0A/pitITWzfxGulK7SLQ4RCwMSm4Yi+2Pc96dzLggwUZSZuNXqm/bEuaIPcU+t41eM2E="
    ];
  };

  environment.systemPackages = with pkgs; [
    jq
    git
    caddy
    goaccess
    devenv
    screen
    docker-compose
  ];

  systemd.services.hotels-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve hotels.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = hotelsProjectRoot;
      EnvironmentFile = "${hotelsProjectRoot}/.env";
      ExecStartPre = "${hotelsProjectRoot}/.devenv/state/venv/bin/python manage.py collectstatic --noinput";
      ExecStart = "${hotelsProjectRoot}/.devenv/state/venv/bin/gunicorn -w 4 --bind 127.0.0.1:8001 hotels.wsgi";
    };
    environment = {
      PATH = lib.mkForce "${hotelsProjectRoot}/.devenv/state/venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.swarje-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve swarje.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = swarjeProjectRoot;
      ExecStart = "${swarjeProjectRoot}/.devenv/state/venv/bin/gunicorn -w 8 --bind 127.0.0.1:8002 run:app";
    };
    environment = {
      PATH = lib.mkForce "${swarjeProjectRoot}/.devenv/state/venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.deploy-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve deploy.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = deployProjectRoot;
      ExecStart = "${deployProjectRoot}/.devenv/state/venv/bin/uvicorn main:app --port 8007";
    };
    environment = {
      PATH = lib.mkForce "${deployProjectRoot}/.devenv/state/venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.blocket-api-se = {
    enable = true;
    description = "Gunicorn instance to serve blocket-api.se api";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = blocketapiProjectRoot;
      ExecStart = "${blocketapiProjectRoot}/.venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker api:app -b 127.0.0.1:8008 --access-logfile - --error-logfile - --log-level info";
    };
    environment = {
      PATH = lib.mkForce "${blocketapiProjectRoot}/.venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.wcwp = {
    enable = true;
    description = "Gunicorn instance to serve wcwp";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = wcwpProjectRoot;
      ExecStart = "${wcwpProjectRoot}/.venv/bin/gunicorn -w 4 --bind 127.0.0.1:8009 run:app";
    };
    environment = {
      PATH = lib.mkForce "${wcwpProjectRoot}/.venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.caddy-to-seq = {
    description = "Forward Caddy logs to Seq";
    wantedBy = ["multi-user.target"];
    after = ["caddy.service"];

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/tail -F -n 0 /var/log/caddy/access-blocket-api.se.log | /home/emil/projects/seq/.venv/bin/python3 /home/emil/projects/seq/main.py'";
      Restart = "always";
    };
  };

  systemd.services.metrics-to-seq = {
    description = "Send system metrics to Seq";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    serviceConfig = {
      ExecStart = "/home/emil/projects/seq/.venv/bin/python3 /home/emil/projects/seq/metrics.py";
      Restart = "always";
      RestartSec = "60s";
    };
  };

  system.stateVersion = "24.05";
}
