{
  pkgs,
  home,
  ...
}: {
  programs.zed-editor = {
    enable = true;

    userSettings = {
      show_signature_help_after_edits = true;
      git = {
        inline_blame = {
          show_commit_summary = true;
        };
      };
    };

    mutableUserKeymaps = false;
    userKeymaps = [
      {
        "context" = "Workspace";
        "bindings" = {
          "ctrl-shift-t" = "terminal_panel::ToggleFocus";
        };
      }
      {
        "context" = "Terminal";
        "bindings" = {
          "ctrl-shift-t" = "terminal_panel::ToggleFocus";
          "ctrl-shift-space" = "workspace::ActivatePaneUp";
          "ctrl-n" = "workspace::NewTerminal";
          "alt-up" = "workspace::ActivatePaneUp";
          "alt-down" = "workspace::ActivatePaneDown";
          "ctrl-shift-k" = "pane::SplitDown";
        };
      }
    ];
    mutableUserSettings = false;
    userSettings = {
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
      terminal.dock = "right";
      features.edit_prediction_provider = "zed";
    };
  };

  home.file.".config/zed/snippets/python.json".text = builtins.toJSON {
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
