{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "emil-hp";

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["root" "emil"];

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

  services.xserver.enable = true;
  services.tailscale.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  virtualisation.docker.enable = true;

  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "";
  };

  # enabling yubikey support
  services.pcscd.enable = true;

  console.keyMap = "sv-latin1";

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur =
      import (builtins.fetchTarball {
        url = "https://github.com/nix-community/NUR/archive/3a6a6f4da737da41e27922ce2cfacf68a109ebce.tar.gz";
        sha256 = "04387gzgl8y555b3lkz9aiw9xsldfg4zmzp930m62qw8zbrvrshd";
      }) {
        inherit pkgs;
      };
  };
  users.users.emil = {
    isNormalUser = true;
    description = "emil";
    extraGroups = ["networkmanager" "wheel" "docker"];
    shell = pkgs.fish;
    packages = with pkgs; [
      slack
      firefox
      thunderbird
      telegram-desktop
      comma
      delta
      direnv
      libreoffice
      dbeaver-bin
      kitty
      tailscale
      insomnia
      openssl
      spotify
      nodejs
      docker
      poetry
      ngrok
      yubikey-manager
      (
        vscode-with-extensions.override {
          vscodeExtensions = with pkgs.vscode-extensions;
            [
              ms-python.python
              ms-python.vscode-pylance
              ms-python.black-formatter
              vscode-icons-team.vscode-icons
              hashicorp.terraform
              batisteo.vscode-django
              eamodio.gitlens
              skellock.just
              bbenoist.nix
              esbenp.prettier-vscode
              stylelint.vscode-stylelint
              dbaeumer.vscode-eslint
              editorconfig.editorconfig
              charliermarsh.ruff
            ]
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "mypy-type-checker";
                publisher = "ms-python";
                version = "2023.9.11501016";
                sha256 = "sha256-mHc+yT4yw+jkRd1j409C7OJzg4jg6dKMgbE8/5cBUxw=";
              }
              {
                name = "code-spell-checker";
                publisher = "streetsidesoftware";
                version = "4.0.15";
                sha256 = "sha256-Zow0laXwORa3V5Hy40pWDa/+Xq7kQbgn/Ia6PrJxI6E=";
              }
              {
                name = "toml";
                publisher = "be5invis";
                version = "0.6.0";
                sha256 = "yk7buEyQIw6aiUizAm+sgalWxUibIuP9crhyBaOjC2E=";
              }
              {
                name = "vscode-direnv";
                publisher = "rubymaniac";
                version = "0.0.2";
                sha256 = "TVvjKdKXeExpnyUh+fDPl+eSdlQzh7lt8xSfw1YgtL4=";
              }
            ];
        }
      )
    ];
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.vitals
    alejandra
    pre-commit
  ];

  # pro tip: use "dconf watch /" to figure out the paths
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          # extensions
          "org/gnome/shell" = {
            disabled-extensions = "";
            enabled-extensions = [
              "dash-to-dock@micxgx.gmail.com"
              "Vitals@CoreCoding.com"
            ];
          };

          # extensions config
          "org/gnome/shell/extensions/dash-to-dock" = {
            dock-position = "LEFT";
            dash-max-icon-size = "20";
            extend-height = true;
            custom-theme-shrink = true;
            apply-custom-theme = true;
            show-icons-emblems = false;
          };
          "org/gnome/shell/extensions/vitals" = {
            hot-sensors = [
              "_memory_usage_"
              "__network-rx_max__"
              "_processor_usage_"
              "_storage_free_"
              "_temperature_acpi_thermal zone_"
            ];
          };

          # desktop
          "org/gnome/desktop/wm/preferences".button-layout = "minimize,maximize,close";
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";
          "org/gnome/desktop/interface".show-battery-percentage = true;
          "org/gnome/desktop/interface".clock-show-seconds = true;
          "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
          "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;

          # keybindings
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            name = "terminal";
            command = "kitty";
            binding = "<Ctrl><Alt>t";
          };
        };
      }
    ];
  };
  system.stateVersion = "23.05";
}
