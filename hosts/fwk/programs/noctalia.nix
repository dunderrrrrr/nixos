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
        concave_edge_corners = false;
        radius = 0;

        start = [
          "session"
          "launcher"
          "power_profile"
          "wallpaper"
          "workspaces"
        ];
        center = [
          "date"
          "clock"
          "weather"
        ];
        end = [
          "cpu"
          "ram"
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

      widget.date = {
        format = "{:%Y-%m-%d}";
      };

      widget.weather = {
        show_condition = false;
      };

      widget.ram = {
        type = "sysmon";
        stat = "ram_pct";
      };
    };
  };
}
