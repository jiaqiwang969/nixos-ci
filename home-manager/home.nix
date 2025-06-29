# Home Manager 配置文件
# 用于配置用户环境
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # 导入其他 home-manager 模块
  imports = [
    # 可以在这里导入其他配置文件
    # ./programs.nix
    # ./shell.nix
  ];

  # Nixpkgs 配置
  nixpkgs = {
    # 允许非自由软件
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # 用户信息
  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
  };

  # 基本软件包
  home.packages = with pkgs; [
    # 开发工具
    git
    vim
    htop
    tmux
    
    # 网络工具
    curl
    wget
    
    # 系统工具
    tree
    ncdu
    ripgrep
    fd
  ];

  # Git 配置
  programs.git = {
    enable = true;
    userName = "CI User";
    userEmail = "ci@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Bash 配置
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  # 启用 home-manager
  programs.home-manager.enable = true;

  # 系统服务重载配置
  systemd.user.startServices = "sd-switch";

  # Home Manager 状态版本
  home.stateVersion = "24.05";
} 