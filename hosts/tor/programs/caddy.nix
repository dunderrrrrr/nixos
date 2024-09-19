{services, ...}: {
  services.caddy = {
    enable = true;

    virtualHosts = {
      ":80" = {
        extraConfig = ''
          root * /var/www/html/
          file_server
          encode gzip
        '';
      };
    };
  };
}
