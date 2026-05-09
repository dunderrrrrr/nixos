{
  lib,
  pkgs,
  ...
}: let
  constants = import ../_shared_configs/constants.nix;
  serviceUsers = ["blocket"];
  mkServiceUser = name: {
    isSystemUser = true;
    group = name;
    home = "/home/${name}";
    createHome = true;
    shell = pkgs.fish;
  };
in {
  users.groups = lib.genAttrs serviceUsers (_: {}) // {vector = {};};
  users.users =
    lib.genAttrs serviceUsers mkServiceUser
    // {
      vector = {
        isSystemUser = true;
        group = "vector";
        extraGroups = ["users"];
      };
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
