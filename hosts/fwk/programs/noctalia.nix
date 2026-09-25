{...}: {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      shell.font_family = "JetBrains Mono";

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Kanagawa";
      };

      location.address = "Norrköping, Sweden";

      bar.main = {
        margin_ends = 0;
        margin_edge = 0;

        center = [
          "date"
          "clock"
          "weather"
        ];
        end = [
          "cpu"
          "network_rx"
          "network_tx"
          "spacer"
          "network"
          "bluetooth"
          "volume"
          "spacer"
          "notifications"
          "tray"
          "battery"
        ];
      };

      widget.clock = {
        format = "{:%H:%M:%S}";

        capsule = true;
        capsule_fill = "surface_variant";
        capsule_opacity = 0.6;
      };
    };
  };
}
