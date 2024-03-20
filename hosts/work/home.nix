{ pkgs, ...}:

{
    imports = [
        ./programs/vscode.nix
        ./programs/git.nix
        ./programs/firefox.nix
        ./programs/terminator.nix
    ];

    home.stateVersion = "23.11";
    
    programs.direnv.enable = true; 
}