{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-deltachat-relay.url = "github:dunderrrrrr/nixos-deltachat-relay";
    nixos-deltachat-relay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    alejandra,
    nixos-deltachat-relay,
    ...
  } @ inputs: {
    nixosConfigurations.nixos-public = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-deltachat-relay.nixosModules.deltachat-relay
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
    nixosConfigurations.nixos-blocket = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos-blocket/configuration.nix
        ./hosts/_shared_configs/config.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emil = import ./hosts/nixos-blocket/home.nix;
        }
      ];
    };
    nixosConfigurations.fwk = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
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
    nixosConfigurations.nixos-ha = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos-ha/configuration.nix
        ./hosts/_shared_configs/config.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.emil = import ./hosts/nixos-ha/home.nix;
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

    apps.x86_64-linux.deploy = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      deployScript = pkgs.writeShellApplication {
        name = "deploy";
        runtimeInputs = [pkgs.openssh];
        text = ''
          if [ $# -lt 1 ]; then
            echo "Usage: deploy <host>[,<host>...]" >&2
            exit 1
          fi

          IFS=',' read -ra HOSTS <<< "$1"

          for host in "''${HOSTS[@]}"; do
            echo "==> Deploying $host"
            ssh -t "emil@$host" "cd ~/nix && git pull && sudo nixos-rebuild switch --flake .#$host"
          done
        '';
      };
    in {
      type = "app";
      program = "${deployScript}/bin/deploy";
    };
  };
}
