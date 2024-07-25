{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = github:nix-community/NUR;

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    alejandra,
    ...
  } @ inputs: {
    nixosConfigurations.work = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {nixpkgs.overlays = [nur.overlay];}

        ./hosts/work/configuration.nix
        ./hosts/_shared_configs/config.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emil = import ./hosts/work/home.nix;
        }
      ];
    };
    nixosConfigurations.public-www = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/public-www/configuration.nix
        ./hosts/_shared_configs/config.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emil = import ./hosts/public-www/home.nix;
        }
      ];
    };
    nixosConfigurations.nixos-pelme = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos-pelme/configuration.nix
        ./hosts/_shared_configs/config.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emil = import ./hosts/nixos-pelme/home.nix;
        }
      ];
    };

    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        packages = [
          pkgs.pre-commit
        ];
        shellHook = ''
          pre-commit install --overwrite
        '';
      };
  };
}
