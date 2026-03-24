{
  pkgs,
  home,
  ...
}: {
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Niji";

      window-width = 160;
      window-height = 45;

      font-family = "JetBrains Mono";
      font-size = 11;
      background-opacity = 0.8; # 0.0 = fully transparent, 1.0 = fully opaque

      keybind = [
        "alt+left=goto_split:left"
        "alt+right=goto_split:right"
        "alt+up=goto_split:up"
        "alt+down=goto_split:down"
      ];
    };
  };

  xdg.configFile."ghostty/config".force = true;
}
