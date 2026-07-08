{
  config,
  lib,
  pkgs,
  ...
}: let
  blocketapiProjectRoot = "/home/blocket/blocket-api.se";
  blocketDocsProjectRoot = "/home/blocket/blocket_api";
in {
  imports = [
    ./caddy.nix
    ./hardware-configuration.nix
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nixos-blocket";

  networking.firewall.allowedTCPPorts = [
    22228
    80
    443
  ];

  environment.systemPackages = with pkgs; [
    jq
    git
    caddy
    screen
    docker-compose
    direnv
  ];

  services = {
    openssh = {
      enable = true;
      ports = [22228];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    journald.extraConfig = ''
      SystemMaxUse=300M
      SystemMaxFileSize=40M
      MaxRetentionSec=4day
    '';

    vector = {
      enable = true;
      settings = {
        ## Host metrics
        sources.host_metrics = {
          type = "host_metrics";
          collectors = ["cpu" "memory" "disk"];
          scrape_interval_secs = 15;
        };
        transforms.metrics_to_log = {
          type = "metric_to_log";
          inputs = ["host_metrics"];
        };
        transforms.parse_host_metrics = {
          type = "remap";
          inputs = ["metrics_to_log"];
          source = ''
            ._msg = .name
            .host = get_hostname!()
          '';
        };

        ## Caddy
        sources.caddy_logs = {
          type = "file";
          include = ["/var/log/caddy/*.log"];
        };
        transforms.parse_caddy = {
          type = "remap";
          inputs = ["caddy_logs"];
          source = ''
            . = parse_json!(.message)
            ._msg = .msg
               .country = string!(.request.headers."Cf-Ipcountry"[0])
               .request_path = split!(.request.uri, "?")[0]
          '';
        };

        ## Sinks
        sinks.victorialogs = {
          type = "elasticsearch";
          inputs = ["parse_caddy"];
          endpoints = ["http://127.0.0.1:9428/insert/elasticsearch/"];
          mode = "bulk";
          api_version = "v8";
          request.headers = {
            AccountID = "0";
            ProjectID = "0";
            VL-Stream-Fields = "host,logger";
          };
        };
        sinks.victoriametrics = {
          type = "prometheus_remote_write";
          inputs = ["host_metrics"];
          endpoint = "http://127.0.0.1:8428/api/v1/write";
        };
      };
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

  systemd.services = {
    api = {
      enable = true;
      description = "Gunicorn instance to serve the api";
      after = ["network.target"];
      serviceConfig = {
        User = "blocket";
        WorkingDirectory = blocketapiProjectRoot;
        ExecStart = "${blocketapiProjectRoot}/.venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker api:app -b 127.0.0.1:8000 --access-logfile - --error-logfile - --log-level info";
      };
      environment = {
        PATH = lib.mkForce "${blocketapiProjectRoot}.venv/bin/";
      };
      wantedBy = ["multi-user.target"];
    };
    docs = {
      enable = true;
      description = "Gunicorn instance to serve the docs";
      after = ["network.target"];
      serviceConfig = {
        User = "blocket";
        WorkingDirectory = blocketDocsProjectRoot;
        ExecStart = "${blocketDocsProjectRoot}/.venv/bin/gunicorn docs.app:app --workers 2 -b 127.0.0.1:8001 --access-logfile - --error-logfile - --log-level info";
      };
      environment = {
        PATH = lib.mkForce "${blocketDocsProjectRoot}.venv/bin/";
      };
      wantedBy = ["multi-user.target"];
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/log/caddy 0755 caddy users -"
    "d /var/lib/victorialogs 0755 root root -"
    "d /var/lib/grafana 0755 472 472 -"
    "d /var/lib/victoriametrics 0755 root root -"
  ];

  virtualisation.oci-containers.containers = {
    victorialogs = {
      image = "victoriametrics/victoria-logs:latest";
      ports = ["127.0.0.1:9428:9428"];
      volumes = [
        "/var/lib/victorialogs:/vlogs"
      ];
      cmd = [
        "-storageDataPath=/vlogs"
        "-retentionPeriod=4w"
      ];
    };

    grafana = {
      image = "grafana/grafana:latest";
      ports = ["127.0.0.1:3000:3000"];
      extraOptions = ["--network=host"];
      volumes = [
        "/var/lib/grafana:/var/lib/grafana"
      ];
      environment = {
        GF_SERVER_ROOT_URL = "https://logs.blocket-api.se";
        GF_SERVER_DOMAIN = "logs.blocket-api.se";
        GF_INSTALL_PLUGINS = "victoriametrics-logs-datasource";
      };
    };

    victoriametrics = {
      image = "victoriametrics/victoria-metrics:latest";
      ports = ["127.0.0.1:8428:8428"];
      volumes = ["/var/lib/victoriametrics:/storage"];
      cmd = [
        "-storageDataPath=/storage"
        "-retentionPeriod=4w"
      ];
    };
  };

  system.stateVersion = "24.05";
}
