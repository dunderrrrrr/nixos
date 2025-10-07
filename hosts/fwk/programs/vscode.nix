{pkgs, ...}: {
  programs.vscode = {
    enable = true;

    profiles.default = {
      # enableUpdateCheck = false; # Disable VSCode self- update and let Home Manager to manage VSCode versions instead.
      # enableExtensionUpdateCheck = false; # Disable extensions auto - update and let nix4vscode manage updates and extensions
      # extensions = pkgs.nix4vscode.forVscode [
      #   "ms-python.python"
      #   "ms-python.vscode-pylance"
      #   "ms-python.black-formatter"
      #   "vscode-icons-team.vscode-icons"
      #   "hashicorp.terraform"
      #   "batisteo.vscode-django"
      #   "eamodio.gitlens"
      #   "bbenoist.nix"
      #   "esbenp.prettier-vscode"
      #   "stylelint.vscode-stylelint"
      #   "dbaeumer.vscode-eslint"
      #   "editorconfig.editorconfig"
      #   "charliermarsh.ruff"
      #   "supermaven.supermaven"
      #   "matangover.mypy"
      #   # "oderwat.indent-rainbow"
      # ];
      userSettings = {
        "workbench.colorTheme" = "Monokai";
        "workbench.iconTheme" = "vscode-icons";
        "workbench.list.smoothScrolling" = true;
        "workbench.editor.wrapTabs" = true;

        "vsicons.presets.foldersAllDefaultIcons" = true;
        "explorer.confirmDragAndDrop" = false;

        "editor.formatOnSave" = true;
        "editor.stickyScroll.enabled" = true;
        "editor.minimap.showSlider" = true;
        "editor.multiCursorLimit" = 99999999;

        "editor.smoothScrolling" = true;
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";

        "terminal.integrated.tabs.enabled" = false;
        "terminal.integrated.altClickMovesCursor" = false;
        "terminal.integrated.scrollback" = 9999999999;
        "terminal.integrated.smoothScrolling" = true;
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.stickyScroll.enabled" = false;

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
        {
          key = "alt+down";
          command = "workbench.action.terminal.focusNextPane";
          when = "terminalFocus";
        }
        {
          key = "alt+up";
          command = "workbench.action.terminal.focusPreviousPane";
          when = "terminalFocus";
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
  };
}
