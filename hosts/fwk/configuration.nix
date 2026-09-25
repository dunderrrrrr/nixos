{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./programs/jj-github-send.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "emil-fwk";
  networking.extraHosts = ''
    192.168.50.45 esp.ha.home
  '';
  networking.networkmanager.enable = true;

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

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  programs.virt-manager.enable = true;

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
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.noctalia-greeter}/bin/noctalia-greeter-session -- --session Niri";
  };

  programs.niri.enable = true;
  services.displayManager.defaultSession = lib.mkForce "niri";

  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  console.keyMap = "sv-latin1";

  services.printing.enable = true;
  services.fwupd.enable = true; # https://wiki.nixos.org/wiki/Hardware/Framework/Laptop_13
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

  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  users.users.emil = {
    isNormalUser = true;
    description = "emil";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "dialout"
      "libvirtd"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      gnupg
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
      yubikey-manager
      devenv
      jujutsu
      gnome-disk-utility
      metasploit
      nmap
      kdePackages.kalk
      hashcat
      nixfmt
      jjui
      ghostty
      jetbrains-mono
      gram
      # gram related
      clang
      rustup
      vscode-langservers-extracted
      typescript-language-server
      python313Packages.python-lsp-server
      vtsls
      ty
      basedpyright
      sops
    ];
  };

  fonts.packages = [pkgs.jetbrains-mono];
  fonts.fontconfig.defaultFonts.monospace = ["JetBrains Mono"];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
