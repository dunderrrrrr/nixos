{...}: {
  wayland.windowManager.niri = {
    enable = true;

    enableDefaultConfig = true;

    settings = {
      prefer-no-csd = {};
      input = {
        touchpad = {
          tap = {};
          accel-profile = "flat";
        };
        mouse.accel-profile = "flat";
      };

      layout = {
        gaps = 12;

        focus-ring = {
          width = 2;
          active-gradient._props = {
            from = "#6b3a3a";
            to = "#3a4a6b";
            angle = 45;
          };
          inactive-color = "#4c566a";
        };

        shadow.on = {};
      };

      animations = {
        window-open.duration-ms = 150;
        window-close.duration-ms = 150;
        workspace-switch.duration-ms = 200;
      };

      _children = [
        {spawn-at-startup._args = ["noctalia-shell"];}
        {
          recent-windows.previews = {
            max-height = 120;
            max-scale = 0.15;
          };
        }
        {
          window-rule = {
            geometry-corner-radius._args = [10];
            clip-to-geometry = true;
          };
        }
        {
          window-rule = {
            match._props.is-active = false;
            opacity._args = [0.82];
          };
        }
      ];

      binds."Super+Space" = {
        _props.hotkey-overlay-title = "Open Launcher";
        spawn = ["noctalia" "msg" "panel-toggle" "launcher"];
      };
      binds."Ctrl+Alt+L" = {
        _props.hotkey-overlay-title = "Lock Screen";
        spawn = ["noctalia" "msg" "session" "lock"];
      };
      binds."Ctrl+Alt+T" = {
        _props.hotkey-overlay-title = "Open a Terminal: ghostty";
        spawn = ["ghostty"];
      };
      binds."Ctrl+Alt+F" = {
        _props.hotkey-overlay-title = "Open Firefox";
        spawn = ["firefox"];
      };

      binds."Ctrl+Alt+S" = {
        _props.hotkey-overlay-title = "Open Slack";
        spawn = ["slack"];
      };

      binds."Print" = {
        _props.hotkey-overlay-title = "Screenshot (region, annotate)";
        spawn = [
          "sh"
          "-c"
          "grim -g \"$(slurp)\" - | satty --filename - --output-filename ~/Pictures/screenshots/satty-$(date +%Y%m%d-%H%M%S).png --early-exit --initial-tool brush --copy-command 'wl-copy'"
        ];
      };

      binds."Mod+Down" = {
        _props.hotkey-overlay-title = "Focus Window Below";
        focus-window-or-workspace-down = {};
      };
      binds."Mod+Up" = {
        _props.hotkey-overlay-title = "Focus Window Above";
        focus-window-or-workspace-up = {};
      };
      binds."Mod+F" = {
        _props.hotkey-overlay-title = "Maximize window";
        maximize-window-to-edges = {};
      };
    };
  };

  xdg.configFile."niri/config.kdl".force = true;
}
