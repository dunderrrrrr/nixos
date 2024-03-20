{ pkgs, ... }:
{
programs.terminator = {
    enable = true;
    config = {
        global_config = {
            handle_size = 4;
            inactive_color_offset = "0.7045454545454546";
        };
        profiles.default = {
            background_color = "#282828";
            background_darkness = 0.93;
            foreground_color = "#ebdbb2";
            show_titlebar = false;
            scrollback_infinite = true;
            palette = "#282828:#cc241d:#98971a:#d79921:#458588:#b16286:#689d6a:#a89984:#928374:#fb4934:#b8bb26:#fabd2f:#83a598:#d3869b:#8ec07c:#ebdbb2";
            title_transmit_bg_color = "#282828";
        };
        layouts.default = {
            window0 = {
                type = "Window";
                parent = "";
            };
            child1 = {
                type = "Terminal";
                parent = "window0";
                profile = "default";
            };
        };
    };
};
}