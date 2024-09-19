{services, ...}: {
  services.tor = {
    enable = true;
    relay.onionServices = {
      # pkollen2w5thfevzjyjq5rvlxq5q35biphyn7wxk2jyoz6vmk3rtrqyd.onion
      "pkollen/www" = {
        map = [
          80
        ];
      };
      # perskolu6ih4x7piduu25bay6ys6kj46d6xpazfumthv24d4imcr2sqd.onion
      "perskol/www" = {
        map = [
          80
        ];
      };
    };
  };
}
