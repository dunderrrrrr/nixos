{ pkgs, ...}:

{
    imports = [
        ./programs/vscode.nix
        ./programs/git.nix
        ./programs/firefox.nix
    ];

    home.stateVersion = "23.11";

    programs.direnv.enable = true; 
}