{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    userSettings = {
      "workbench.colorTheme" = "Monokai";
      "workbench.iconTheme" = "vscode-icons";
      "vsicons.presets.foldersAllDefaultIcons" = true;
      "explorer.confirmDragAndDrop" = false;

      "editor.formatOnSave" = true;
      "editor.stickyScroll.enabled" = true;
      "editor.minimap.showSlider" = true;
      "editor.multiCursorLimit" = 99999999;

      "terminal.integrated.tabs.enabled" = false;
      "terminal.integrated.altClickMovesCursor" = false;
      "terminal.integrated.scrollback" = 9999999999;

      "window.titleBarStyle" = "custom";
      "window.customMenuBarAltFocus" = false;
      "window.enableMenuBarMneMonics" = false;
      "window.menuBarVisibility" = "visible";
      "window.zoomLevel" = -1;
    };
    keybindings = [
      {
        key = "ctrl+shift+[minus]";
        command = "workbench.action.focusActiveEditorGroup";
      }
    ];
    globalSnippets = {
      pin = {
        prefix = ["pin"];
        description = "Inserts full pin word";
        body = ["personal_identification_number"];
      };
      type_checking = {
        prefix = ["type_checking"];
        description = "Inserts TYPE_CHECKING block";
        body = [
          "from __future__ import annotations"
          "from typing import TYPE_CHECKING"
          ""
          "if TYPE_CHECKING:"
          "    "
        ];
      };
      template_script = {
        prefix = ["template_script"];
        description = "Inserts a simple PK script starter template";
        body = [
          "import click"
          ""
          "from pk.utils.cli import command"
          ""
          "@command()"
          "@click.option(\"--commit\", is_flag=True, default=False)"
          "def main(commit):"
          ""
          "    assert commit"
          "if __name__ == \"__main__\":"
          "    main()"
        ];
      };
      breakpoint = {
        prefix = ["bkp"];
        description = "Inserts breakpoint()";
        body = [
          "breakpoint()"
        ];
      };
    };
  };
}
