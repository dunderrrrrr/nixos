{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "emil-fwk";
  networking.extraHosts = ''
    192.168.50.11 esp.ha.home
  '';
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["root" "emil"];

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;

  services.pcscd.enable = true; # yubikey support

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

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  console.keyMap = "sv-latin1";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.ssh.startAgent = true;

  users.users.emil = {
    isNormalUser = true;
    description = "emil";
    extraGroups = ["networkmanager" "wheel" "docker" "dialout"];
    shell = pkgs.fish;
    packages = with pkgs; [
      slack
      chromium
      firefox
      thunderbird
      deltachat-desktop
      delta
      direnv
      libreoffice
      dbeaver-bin
      tailscale
      insomnia
      openssl
      nodejs
      docker
      poetry
      yubikey-manager
      devenv
      jujutsu
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
              supermaven.supermaven
              matangover.mypy
            ]
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
  system.stateVersion = "24.11";
}
