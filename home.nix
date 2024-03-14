{ pkgs, ...}:

{
    home.stateVersion = "23.11";

    programs.direnv.enable = true;   

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
        keybindings = [{
            key = "ctrl+shift+[minus]";
            command = "workbench.action.focusActiveEditorGroup";
        }];
    };

    programs.git = {
        enable = true;
        userName = "Emil";
        userEmail = "emil@personalkollen.se";

        extraConfig = {
            push.default = "current";
            pull.rebase = true;
            commit.template = "${./templates/git_commit.txt}";

            # delta git diff
            core.pager = "${pkgs.delta}/bin/delta";
            interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
            delta.navigate = true;
            delta.light = false;
            merge.conflictstyle = "diff3";
            diff.colorMoved = "default";
        };
    };

    programs.firefox = {
        enable = true;
        profiles.default = {
            isDefault = true;
            settings = {
                "browser.startup.homepage" = "about:blank";
            };
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
                onepassword-password-manager
                ublock-origin
                bitwarden
            ];
        };
    };
}