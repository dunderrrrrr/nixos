{services, ...}: {
  services.caddy = {
    enable = true;

    virtualHosts = {
      "mat.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:3500
          file_server
        '';
      };

      "hotels.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:4000
          file_server

          handle /static/* {
              root * /home/public/hotels.dunderrrrrr.se/data
              file_server
          }
        '';
      };
    };
  };
}
