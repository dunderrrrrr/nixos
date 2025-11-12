{
  config,
  lib,
  pkgs,
  ...
}: {
  services.caddy = {
    group = "users";
    enable = true;

    virtualHosts = {
      "hotels.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8001

          handle_path /static/* {
            root * /srv/hotels.dunderrrrrr.se/data
            file_server
          }'';
      };

      "swarje.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8002
          file_server
        '';
      };

      "huslogg.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8004
          file_server
        '';
      };
      "deploy.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8007
          file_server
        '';
      };
      "blocket-api.se" = {
        extraConfig = ''
          root * /srv/blocket-api/
          file_server

          @api path /v1* /swagger*
          reverse_proxy @api http://127.0.0.1:8008
        '';
      };
      "wcwp.dunderrrrrr.se" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8009
          file_server
        '';
      };
    };
  };
}
