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
  };
}
