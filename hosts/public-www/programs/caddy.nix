{services, ...}: {
  services.caddy = {
    enable = true;

    virtualHosts = {
      ####################
      ## DUNDERRRRRR.SE ##
      ####################
      "dunderrrrrr.se" = {
        serverAliases = ["www.dunderrrrrr.se"];
        extraConfig = ''
          redir https://github.com/dunderrrrrr
        '';
      };
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
              root * /var/www/html/hotels.dunderrrrrr.se/data
              file_server
          }
        '';
      };
      ###############
      ## TELSÖK.SE ##
      ###############
      "xn--telsk-mua.se" = {
        serverAliases = ["www.xn--telsk-mua.se"];
        extraConfig = ''
          reverse_proxy 127.0.0.1:9191
          file_server
        '';
      };
      #################
      ## FÖRSENAD.SE ##
      #################
      "xn--frsenad-90a.se" = {
        serverAliases = ["www.xn--frsenad-90a.se"];
        extraConfig = ''
          reverse_proxy 127.0.0.1:9500
          file_server

          handle /static/* {
              root * /var/www/html/forsenad/data
              file_server
          }
        '';
      };
      ####################
      ## TILDE.PELME.SE ##
      ####################
      "tilde.pelme.se" = {
        extraConfig = ''
          reverse_proxy 10.3.3.10:8000
          file_server
        '';
      };
    };
  };
}
