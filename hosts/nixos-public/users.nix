{pkgs, ...}: {
  users.groups.hotels = {};

  users.users.hotels = {
    isSystemUser = true;
    group = "hotels";
    home = "/home/hotels";
    createHome = true;
    shell = pkgs.bash;
  };
}
