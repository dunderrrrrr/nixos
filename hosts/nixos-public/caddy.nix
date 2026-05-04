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
      "hotels.dunderrrrrr.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy 127.0.0.1:8001

          handle_path /static/* {
            root * /srv/hotels.dunderrrrrr.se/data
            file_server
          }'';
      };

      "swarje.dunderrrrrr.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy 127.0.0.1:8002
          file_server
        '';
      };

      "huslogg.dunderrrrrr.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy 127.0.0.1:8004
          file_server
        '';
      };
      "wcwp.dunderrrrrr.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy 127.0.0.1:8009
          file_server
        '';
      };
      "brygglogg.dunderrrrrr.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy 127.0.0.1:8011
          file_server
        '';
      };
      "domänfluff.dunderrrrrr.se" = {
        extraConfig = ''
          import secure_headers
          reverse_proxy 127.0.0.1:8012
          file_server
        '';
      };
    };
  };
}
