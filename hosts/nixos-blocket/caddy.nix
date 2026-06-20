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
          import secure_headers

          log {
            output file /var/log/caddy/access-blocket-api.se.log {
              mode 0640
            }
            format json
            level INFO
          }

          root * /srv/blocket-api/
          file_server

          handle /ads.txt {
            respond "google.com, pub-5870606260695974, DIRECT, f08c47fec0942fa0" 200
          }

          @api path /v1* /swagger*
          reverse_proxy @api http://127.0.0.1:8000

          handle_errors 404 {
            rewrite * /404.html
            file_server
          }
        '';
      };
      "logs.blocket-api.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy http://127.0.0.1:3000
        '';
      };
    };
  };
}
