{
  config,
  pkgs,
  ...
}: let
  constants = import ../_shared_configs/constants.nix;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.firewall.allowedTCPPorts = [
    8123
    80
    443
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-ha";
  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "emil"
  ];

  services.tailscale.enable = true;
  virtualisation.docker.enable = true;

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

  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  console.keyMap = "sv-latin1";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  users.users.emil = {
    isNormalUser = true;
    description = "emil";
    openssh.authorizedKeys.keys = [constants.emilSshKey];
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      git
    ];
  };

  systemd.services.homeassistant-api = {
    description = "FastAPI for HomeAssistant";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "emil";
      # Group = "dock";
      WorkingDirectory = "/home/emil/ha_api";
      ExecStart = "/home/emil/ha_api/.venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000";
      Restart = "always";
    };
  };

  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel run --token \${TUNNEL_TOKEN}";
      EnvironmentFile = "/run/secrets/cloudflared-token";
      Restart = "always";
      DynamicUser = true;
    };
  };

  services.caddy = {
    group = "users";
    enable = true;

    virtualHosts = {
      "esp.ha.home" = {
        extraConfig = ''
          reverse_proxy localhost:6052
          tls internal
        '';
      };
    };
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
