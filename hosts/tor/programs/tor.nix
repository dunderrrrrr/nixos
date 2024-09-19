{services, ...}: {
  services.tor = {
    enable = true;
    relay.onionServices = {
      "example.org/www" = {
        map = [
          80
        ];
      };
    };
  };
}
