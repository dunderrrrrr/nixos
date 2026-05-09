{
  lib,
  pkgs,
  ...
}: let
  serviceUsers = ["blocket"];
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
