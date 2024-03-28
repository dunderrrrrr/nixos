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
              root * /home/public/hotels.dunderrrrrr.se/data
              file_server
          }
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
              root * /home/forsenad/forsenad/data
              file_server
          }
        '';
      };
      ##############
      ## PKLAN.SE ##
      ##############
      "pklan.se" = {
        serverAliases = ["www.pklan.se"];
        extraConfig = ''
          root * /home/public/pklan/public
          file_server
          encode gzip
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
