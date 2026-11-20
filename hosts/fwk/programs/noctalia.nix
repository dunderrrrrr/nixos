{pkgs, ...}: let
  ostgotapendeln-next-train = pkgs.fetchFromGitHub {
    owner = "dunderrrrrr";
    repo = "noctalia-ostgotapendel";
    rev = "main";
    hash = "sha256-shqU44KPoHemnFNo4JdON4yZ+JJLHRbqMTUNYqKi56s=";
  };
in {
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
          "power_profile"
          "workspaces"
          "alexander/screen-toolkit:widget"
          "dunderrrrrr/ostgotapendeln_next_train:bar"
          "active_window"
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
          "network"
          "bluetooth"
          "volume"
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
  # Runtime tools for the alexander/screen-toolkit.
  home.packages = with pkgs; [
    slurp
    hyprpicker
    (tesseract.override {enableLanguages = ["eng" "swe"];})
    imagemagick
    zbar
    qrencode
    curl
    jq
    translate-shell
    ffmpeg
    wl-screenrec
    wf-recorder
    xdg-utils
    pulseaudio # pactl
  ];

  xdg.dataFile."noctalia/plugins/ostgotapendeln_next_train".source =
    ostgotapendeln-next-train;
}
