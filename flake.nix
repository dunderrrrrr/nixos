{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = github:nix-community/NUR;

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    alejandra,
    nix4vscode,
    ...
  } @ inputs: {
    nixosConfigurations.nixos-public = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos-public/configuration.nix
        ./hosts/_shared_configs/config.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emil = import ./hosts/nixos-public/home.nix;
        }
      ];
    };
    nixosConfigurations.fwk = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {nixpkgs.overlays = [nur.overlays.default nix4vscode.overlays.default];}

        ./hosts/fwk/configuration.nix
        ./hosts/_shared_configs/config.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emil = import ./hosts/fwk/home.nix;
        }
      ];
    };
    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        packages = [
          pkgs.pre-commit
          pkgs.alejandra
        ];
        shellHook = ''
          pre-commit install --overwrite
        '';
      };
  };
}
