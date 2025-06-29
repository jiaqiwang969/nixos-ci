# 系统配置文件
# 用于配置系统环境
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # 导入其他 NixOS 模块
  imports = [
    # 导入硬件配置
    ./hardware-configuration.nix
    
    # GitHub CI Runner 配置
    # ./github-runner.nix  # 暂时禁用，先让系统正常启动
    
    # 紧急修复配置
    ./emergency-fix.nix
  ];

  # Nixpkgs 配置
  nixpkgs = {
    # 允许非自由软件
    config = {
      allowUnfree = true;
    };
  };

  # Nix 配置
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # 启用 flakes 和新的 'nix' 命令
      experimental-features = "nix-command flakes";
      # 禁用全局注册表
      flake-registry = "";
      # 解决 https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # 禁用 channels
    channel.enable = false;

    # 使 flake registry 和 nix path 匹配 flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # 引导配置
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # 主机名
  networking.hostName = "nixos-ci";
  
  # 网络管理
  networking.networkmanager.enable = true;

  # 用户配置
  users.users = {
    # root 用户配置
    root = {
      hashedPassword = null;  # 允许无密码（仅紧急情况）
    };
    
    # 主要用户
    nixos = {
      initialPassword = "nixos";  # 首次登录后请修改
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: 在此添加你的 SSH 公钥
      ];
      extraGroups = ["wheel" "networkmanager"];
    };
  };

  # SSH 服务器配置
  services.openssh = {
    enable = true;
    settings = {
      # 禁止 root 通过 SSH 登录
      PermitRootLogin = "no";
      # 允许密码认证（初始设置时需要）
      PasswordAuthentication = true;
    };
  };

  # 命令行界面配置
  # services.getty.autologinUser = "nixos";  # 暂时禁用自动登录
  # systemd.services."getty@tty1".enable = true;
  # systemd.services."getty@tty1".wantedBy = [ "multi-user.target" ];
  
  # 确保控制台输出
  # boot.kernelParams = [ "console=tty1" ];
  
  # 使用命令行模式
  # systemd.defaultUnit = "multi-user.target";

  # 系统状态版本
  system.stateVersion = "24.05";
} 