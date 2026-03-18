{pkgs, ...}: let
  gramConfigDir = ".config/gram";
in {
  imports = [
    ./programs/vscode.nix
    ./programs/git.nix
    ./programs/jujutsu.nix
    ./programs/zed.nix
  ];

  home.stateVersion = "23.11";

  services.ssh-agent.enable = true;

  home.packages = [(pkgs.callPackage ./programs/gram.nix {})];

  home.file."${gramConfigDir}/settings.jsonc".text = builtins.toJSON {
    sticky_scroll = {enabled = true;};
    minimap = {show = "always";};
    smooth_scrolling = true;
    cursor_blink = true;
    cursor_shape = "bar";
    terminal = {
      scrollback_lines = 9999999;
      dock = "right";
    };
    tab_bar = {show = true;};
    vim_mode = false;
    auto_signature_help = true;
    base_keymap = "VSCode";
    show_signature_help_after_edits = true;
    git.inline_blame.show_commit_summary = true;
    icon_theme = {
      mode = "dark";
      light = "Zed (Default)";
      dark = "Material Icon Theme";
    };
    ui_font_size = 16;
    buffer_font_size = 15;
    theme = {
      mode = "dark";
      light = "Gruvbox Light";
      dark = "Gruvbox Dark Hard";
    };
    features.edit_prediction_provider = "none";
  };

  home.file."${gramConfigDir}/keymap.jsonc".text = builtins.toJSON [
    {
      context = "Workspace";
      bindings."ctrl-shift-t" = "terminal_panel::ToggleFocus";
    }
    {
      context = "Terminal";
      bindings = {
        "ctrl-shift-t" = "terminal_panel::ToggleFocus";
        "ctrl-shift-space" = "workspace::ActivatePaneUp";
        "ctrl-n" = "workspace::NewTerminal";
        "alt-up" = "workspace::ActivatePaneUp";
        "alt-down" = "workspace::ActivatePaneDown";
        "ctrl-shift-k" = "pane::SplitDown";
      };
    }
  ];

  home.file."${gramConfigDir}/snippets/python.json".text = builtins.toJSON {
    pin = {
      prefix = "pin";
      body = ["personal_identification_number"];
    };
    type_checking = {
      prefix = "type_checking";
      body = [
        "from __future__ import annotations"
        "from typing import TYPE_CHECKING"
        ""
        "if TYPE_CHECKING:"
        "    "
      ];
    };
    template_script = {
      prefix = "template_script";
      body = [
        "import click"
        ""
        "from pk.utils.cli import command"
        ""
        "@command()"
        ''@click.option("--commit", is_flag=True, default=False)''
        "def main(commit):"
        ""
        "    assert commit"
        ''if __name__ == "__main__":''
        "    main()"
      ];
    };
    breakpoint = {
      prefix = "bkp";
      body = ["breakpoint()"];
    };
  };
}
