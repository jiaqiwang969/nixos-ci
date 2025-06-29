{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-darwin.url = "github:LnL7/nix-darwin";
    ragenix.url = "github:yaxitech/ragenix";
    github-nix-ci.url = "github:juspay/github-nix-ci";
  };
  outputs = inputs: {
    nixosModules.my-github-runners = {
      services.github-nix-ci = {
        age.secretsDir = ./secrets;
        personalRunners = {
          "jiaqiwang969/nixos-ci".num = 1;
        };
        orgRunners = {
        };
      };
    };

    nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.ragenix.nixosModules.default
        inputs.github-nix-ci.nixosModules.default
        inputs.self.nixosModules.my-github-runners
        {
          nixpkgs.hostPlatform = "aarch64-linux";
          
          # 硬件配置
          boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "sr_mod" ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ ];
          boot.extraModulePackages = [ ];

          # 文件系统
          fileSystems."/" = {
            device = "/dev/disk/by-uuid/1e6551fb-6c11-44ed-bb46-f33886b51787";
            fsType = "ext4";
          };

          fileSystems."/boot" = {
            device = "/dev/disk/by-uuid/2343-C9B0";
            fsType = "vfat";
            options = [ "fmask=0022" "dmask=0022" ];
          };

          swapDevices = [ ];

          # 网络配置
          networking.useDHCP = true;

          # 引导配置
          boot.loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
          
          # 用户管理
          users.users.root.hashedPassword = null;  # 允许无密码 root（仅用于紧急情况）
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            initialPassword = "nixos";  # 首次登录后请修改
          };
          
          # 基本服务
          services.getty.autologinUser = "nixos";  # 自动登录（可选）
          services.openssh.enable = true;
          
          # 网络管理
          networking.networkmanager.enable = true;
          
          system.stateVersion = "24.05";
        }
      ];
    };

    darwinConfigurations.example = inputs.nix-darwin.lib.darwinSystem {
      modules = [
        inputs.ragenix.darwinModules.default
        inputs.github-nix-ci.darwinModules.default
        inputs.self.nixosModules.my-github-runners
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          networking.hostName = "example";
          services.nix-daemon.enable = true;
        }
      ];
    };
  };
}
