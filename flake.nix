{
  description = "NixOS configuration for CI runners";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    
    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # Other dependencies
    nix-darwin.url = "github:LnL7/nix-darwin";
    ragenix.url = "github:yaxitech/ragenix";
    github-nix-ci.url = "github:juspay/github-nix-ci";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#nixos-ci'
    nixosConfigurations = {
      nixos-ci = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # 主要的 NixOS 配置文件
          ./nixos/configuration.nix
          
          # Home Manager 作为 NixOS 模块
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = import ./home-manager/home.nix;
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#nixos@nixos-ci'
    homeConfigurations = {
      "nixos@nixos-ci" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home-manager/home.nix];
      };
    };

    # Darwin configuration (保留原有的 macOS 配置)
    darwinConfigurations.example = inputs.nix-darwin.lib.darwinSystem {
      modules = [
        inputs.ragenix.darwinModules.default
        inputs.github-nix-ci.darwinModules.default
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          networking.hostName = "example";
          services.nix-daemon.enable = true;
          
          services.github-nix-ci = {
            age.secretsDir = ./secrets;
            personalRunners = {
              "jiaqiwang969/nixos-ci".num = 1;
            };
            orgRunners = { };
          };
        }
      ];
    };
  };
}
