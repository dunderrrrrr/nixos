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
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+SY+kqLyZDhwcUgS8E+B1jqvKJBI4YcSjehxqJ45AkgqRw/lgTAWhEHzjN/SN0DYt04aSr6flwe2BSAr96MSKJ+QN4RhqjyQbcitaw04Gc5/A09acjsY1a9Hqf3ofmK2OfjacbvN2XaHBuyMixI3Z8t2pm615z+S5mBVxQJHdnCuRF+QH9gZKBPKHkzdIqTBGL+XBCXJLTXCdR8F9yKyIYUTgJdxUhiHpxC98oI38ITjDIyBCmt3WNGXHeDtai0PqMckYcb9xKsM9qXE/1CCrcaBk4pw3yOz4wW3xCHNHKUBoBa9w5E7cTxv5ADQdMfgTQFz2eHe8I0uVwSxR368k9IBPkzqSjEhVIMHEsLS8GyN/oY5UKf1OowmYk+0dJscsDLJL6TMLISIzF5sxp6QufOWXwdMzIkpxIXzTNLjPCvxnQtb7Mc2YbYeBPZV0A/pitITWzfxGulK7SLQ4RCwMSm4Yi+2Pc96dzLggwUZSZuNXqm/bEuaIPcU+t41eM2E="
        ];
      };
    };
}
