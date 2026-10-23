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

          handle /ads.txt {
            respond "google.com, pub-5870606260695974, DIRECT, f08c47fec0942fa0" 200
          }

          @api path /v1* /swagger*
          handle @api {
            reverse_proxy http://127.0.0.1:8000
          }

          handle {
            reverse_proxy http://127.0.0.1:8001
          }
        '';
      };
      "logs.blocket-api.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy http://127.0.0.1:3000
        '';
      };
      "webhooks.blocket-api.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy http://127.0.0.1:8010
        '';
      };
    };
  };
}
