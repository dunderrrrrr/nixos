{
  lib,
  pkgs,
  ...
}: let
  serviceUsers = ["hotels" "swarje" "domanfluff" "wcwp"];
  mkServiceUser = name: {
    isSystemUser = true;
    group = name;
    home = "/home/${name}";
    createHome = true;
    shell = pkgs.fish;
  };
in {
  users.groups = lib.genAttrs serviceUsers (_: {});
  users.users = lib.genAttrs serviceUsers mkServiceUser;
}
