{services, ...}: {
  services.github-runners = {
    forsenad = {
      enable = true;
      replace = true;
      name = "forsenad";
      user = "public";
      tokenFile = "/secrets/forsenad";
      url = "https://github.com/dunderrrrrr/forsenad";
      serviceOverrides = {
        ReadWritePaths = [
          "/var/www/html/forsenad"
        ];
      };
    };
  };
}
