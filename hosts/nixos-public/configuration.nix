{
  config,
  lib,
  pkgs,
  ...
}: let
  hotelsProjectRoot = "/home/emil/projects/hotels.dunderrrrrr.se/";
  matProjectRoot = "/home/emil/projects/mat.dunderrrrrr.se";
  swarjeProjectRoot = "/home/emil/projects/swarje.dunderrrrrr.se";
  badaProjectRoot = "/home/emil/projects/bada.dunderrrrrr.se";
  goodNewsProjectRoot = "/home/emil/projects/good-news.se";
  deployProjectRoot = "/home/emil/projects/nixos-public-deployer";
in {
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

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 * * * *      emil    SECRET_KEY='' /home/emil/projects/kaffeindex/.devenv/state/venv/bin/python /home/emil/projects/kaffeindex/manage.py runscript update_index >> /tmp/cron.log"
    ];
  };

  virtualisation.docker.enable = true;

  time.timeZone = "Europe/Stockholm";

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["root" "emil"];

  console.keyMap = "sv-latin1";

  users.users.emil = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "emil";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+SY+kqLyZDhwcUgS8E+B1jqvKJBI4YcSjehxqJ45AkgqRw/lgTAWhEHzjN/SN0DYt04aSr6flwe2BSAr96MSKJ+QN4RhqjyQbcitaw04Gc5/A09acjsY1a9Hqf3ofmK2OfjacbvN2XaHBuyMixI3Z8t2pm615z+S5mBVxQJHdnCuRF+QH9gZKBPKHkzdIqTBGL+XBCXJLTXCdR8F9yKyIYUTgJdxUhiHpxC98oI38ITjDIyBCmt3WNGXHeDtai0PqMckYcb9xKsM9qXE/1CCrcaBk4pw3yOz4wW3xCHNHKUBoBa9w5E7cTxv5ADQdMfgTQFz2eHe8I0uVwSxR368k9IBPkzqSjEhVIMHEsLS8GyN/oY5UKf1OowmYk+0dJscsDLJL6TMLISIzF5sxp6QufOWXwdMzIkpxIXzTNLjPCvxnQtb7Mc2YbYeBPZV0A/pitITWzfxGulK7SLQ4RCwMSm4Yi+2Pc96dzLggwUZSZuNXqm/bEuaIPcU+t41eM2E="];
  };

  environment.systemPackages = with pkgs; [
    git
    caddy
    devenv
    screen
    docker-compose
  ];

  systemd.services.mat-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve mat.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = matProjectRoot;
      ExecStart = "${matProjectRoot}/.devenv/state/venv/bin/gunicorn -w 4 dash:app";
    };
    environment = {
      PATH = lib.mkForce "${matProjectRoot}/.devenv/state/venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

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

  systemd.services.bada-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve bada.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = badaProjectRoot;
      ExecStart = "${badaProjectRoot}/.devenv/state/venv/bin/gunicorn -w 8 --bind 127.0.0.1:8003 bada:app";
    };
    environment = {
      PATH = lib.mkForce "${badaProjectRoot}/.devenv/state/venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };
  systemd.services.good-news-se = {
    enable = true;
    description = "Pelican server for good-news.se";
    after = ["network.target"];
    serviceConfig = {
      User = "emil";
      WorkingDirectory = goodNewsProjectRoot;
      ExecStart = "${pkgs.bash}/bin/bash -c '${goodNewsProjectRoot}/.devenv/state/venv/bin/pelican content --listen --port 8006'";
    };
    environment = {
      PATH = lib.mkForce "${goodNewsProjectRoot}/.devenv/state/venv/bin/";
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

  services.caddy = {
    group = "users";
    enable = true;

    virtualHosts = {
      "mat.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8000
          file_server
        '';
      };

      "hotels.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8001

          handle_path /static/* {
            root * /srv/hotels.dunderrrrrr.se/data
            file_server
          }'';
      };

      "hus.dunderrrrrr.se" = {
        extraConfig = ''
          root * /srv/hus.dunderrrrrr.se/public
          file_server
        '';
      };

      "swarje.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8002
          file_server
        '';
      };

      "bada.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8003
          file_server
        '';
      };

      "huslogg.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8004
          file_server
        '';
      };
      "money.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8005
          file_server
        '';
      };
      "good-news.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8006
          file_server
        '';
      };
      "deploy.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8007
          file_server
        '';
      };
    };
  };

  system.stateVersion = "24.05";
}
