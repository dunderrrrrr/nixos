{
  lib,
  pkgs,
  ...
}: let
  constants = import ../_shared_configs/constants.nix;
  serviceUsers = ["hotels" "swarje" "domanfluff" "wcwp" "staeder"];
  mkServiceUser = name: {
    isSystemUser = true;
    group = name;
    home = "/home/${name}";
    createHome = true;
    shell = pkgs.fish;
  };
in {
  users.groups = lib.genAttrs serviceUsers (_: {});
  users.users =
    lib.genAttrs serviceUsers mkServiceUser
    // {
      emil = {
        isNormalUser = true;
        shell = pkgs.fish;
        description = "emil";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        packages = with pkgs; [];
        openssh.authorizedKeys.keys = [constants.emilSshKey];
      };
    };
}
