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
  staederProjectRoot = "/home/staeder/staeder";

  deltachatAccountsScript = pkgs.writeScript "deltachat-accounts" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./scripts/deltachat-accounts.py}
  '';
  deltachatAccountsTool = pkgs.runCommand "deltachat-accounts" {} ''
    mkdir -p $out/bin
    ln -s ${deltachatAccountsScript} $out/bin/deltachat-accounts
  '';

  brygglogBackupScript = pkgs.writeScript "brygglogg-backup" ''
    #!${pkgs.stdenv.shell}
    ${builtins.readFile ./scripts/brygglogg-backup.sh}
  '';
in {
  imports = [
    ./caddy.nix
    ./hardware-configuration.nix
    ./users.nix
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets = {
      brygglogg_s3_access_key_id = {};
      brygglogg_s3_secret_access_key = {};
    };

    templates."brygglogg-backup.env".content = ''
      RCLONE_CONFIG_S3_ACCESS_KEY_ID=${config.sops.placeholder.brygglogg_s3_access_key_id}
      RCLONE_CONFIG_S3_SECRET_ACCESS_KEY=${config.sops.placeholder.brygglogg_s3_secret_access_key}
    '';
  };

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
    25
    587
    993
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
  services.deltachat-relay = {
    enable = true;
    domain = "chat.rosamjolk.se";
    acmeEmail = "noreply@rosamjolk.se";
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

  services.journald.settings.Journal = {
    SystemMaxUse = "300M";
    SystemMaxFileSize = "40M";
    MaxRetentionSec = "4day";
  };

  environment.systemPackages = with pkgs; [
    jq
    git
    caddy
    goaccess
    devenv
    screen
    docker-compose
    direnv
    deltachatAccountsTool
    rclone
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
      ExecStart = "${swarjeProjectRoot}/.devenv/state/venv/bin/gunicorn -w 4 --bind 127.0.0.1:8002 run:app";
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

  systemd.services.staeder-dunderrrrrr-se = {
    enable = true;
    description = "Gunicorn instance to serve staeder.dunderrrrrr.se";
    after = ["network.target"];
    serviceConfig = {
      User = "staeder";
      Group = "staeder";
      WorkingDirectory = staederProjectRoot;
      ExecStart = "${staederProjectRoot}/.venv/bin/gunicorn -w 4 --bind 127.0.0.1:8013 run:app";
    };
    environment = {
      PATH = lib.mkForce "${staederProjectRoot}/.venv/bin/";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.brygglogg-backup = {
    description = "Backup brygglogg (Ghost) to S3";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    path = [pkgs.rclone pkgs.gnutar pkgs.gzip];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      EnvironmentFile = config.sops.templates."brygglogg-backup.env".path;
      ExecStart = "${brygglogBackupScript}";
    };
  };

  systemd.timers.brygglogg-backup = {
    description = "Daily backup of brygglogg (Ghost) to S3";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "15min";
    };
  };

  system.stateVersion = "24.05";
}
