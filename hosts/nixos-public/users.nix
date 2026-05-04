{pkgs, ...}: {
  users.groups = {
    hotels = {};
    swarje = {};
    domanfluff = {};
  };

  users.users = {
    hotels = {
      isSystemUser = true;
      group = "hotels";
      home = "/home/hotels";
      createHome = true;
      shell = pkgs.fish;
    };
    swarje = {
      isSystemUser = true;
      group = "swarje";
      home = "/home/swarje";
      createHome = true;
      shell = pkgs.fish;
    };
    domanfluff = {
      isSystemUser = true;
      group = "domanfluff";
      home = "/home/domanfluff";
      createHome = true;
      shell = pkgs.fish;
    };
  };
}
