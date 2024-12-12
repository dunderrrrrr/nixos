{pkgs, ...}: {
  programs.kitty = {
    enable = true;

    themeFile = "Chalk";
    settings = {
      enabled_layouts = "splits";
      scrollback_lines = "4000";
    };

    keybindings = {
      "ctrl+c" = "copy_and_clear_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";

      "ctrl+up" = "neighboring_window up";
      "ctrl+down" = "neighboring_window down";
      "ctrl+left" = "neighboring_window left";
      "ctrl+right" = "neighboring_window right";

      "ctrl+shift+e" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+o" = "launch --location=vsplit --cwd=current";

      "alt+left" = "resize_window narrower 2";
      "alt+right" = "resize_window wider 2";
      "alt+up" = "resize_window taller 2";
      "alt+down" = "resize_window shorter 2";
      "alt+home" = "resize_window reset";
    };
  };
}
