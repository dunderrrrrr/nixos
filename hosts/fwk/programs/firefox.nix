{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:blank";
      };
      search.default = "ddg";
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        onepassword-password-manager
        ublock-origin
        bitwarden
        vimium
      ];
    };
  };
}
