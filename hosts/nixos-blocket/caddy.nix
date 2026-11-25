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
          redir https://https://github.com/dunderrrrrr/blocket_api permanent
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
