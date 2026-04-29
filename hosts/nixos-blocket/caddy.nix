{
  config,
  lib,
  pkgs,
  ...
}: {
  services.caddy = {
    group = "users";
    enable = true;

    extraConfig = ''
      (secure_headers) {
        header {
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
          X-Content-Type-Options "nosniff"
          X-Frame-Options "SAMEORIGIN"
          Referrer-Policy "strict-origin-when-cross-origin"
          -Server
        }
      }
    '';

    virtualHosts = {
      "blocket-api.se" = {
        extraConfig = ''
          root * /srv/blocket-api/
          file_server

          @api path /v1* /swagger*
          reverse_proxy @api http://127.0.0.1:8008

          handle_errors 404 {
            rewrite * /404.html
            file_server
          }
        '';
      };
    };
  };
}
