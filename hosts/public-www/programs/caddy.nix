{services, ...}: {
  services.caddy = {
    enable = true;

    virtualHosts = {
      ":80" = {
        extraConfig = ''
          root * /srv/http
        '';
      };
    };
  };
}
