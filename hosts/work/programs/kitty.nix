{pkgs, ...}: {
  programs.kitty = {
    enable = true;

    theme = "Chalk";
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
    };
  };
}
