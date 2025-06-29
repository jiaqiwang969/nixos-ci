# 安全的 GitHub CI Runner 配置模块
{ config, lib, pkgs, inputs, ... }:

{
  # 导入必要的模块
  imports = [
    inputs.ragenix.nixosModules.default
    inputs.github-nix-ci.nixosModules.default
  ];

  # GitHub CI Runner 服务配置
  services.github-nix-ci = {
    age.secretsDir = ../secrets;
    personalRunners = {
      "jiaqiwang969/nixos-ci".num = 1;
    };
    orgRunners = {
      # 组织级 runners 可以在这里添加
    };
  };

  # 确保 runner 服务不会阻止系统启动
  systemd.services = lib.mapAttrs' (name: value: 
    lib.nameValuePair name {
      wantedBy = lib.mkForce [ ];  # 不自动启动
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        # 如果失败不影响系统启动
        Type = lib.mkDefault "simple";
        Restart = lib.mkDefault "on-failure";
        RestartSec = lib.mkDefault "30s";
      };
    }
  ) (lib.filterAttrs (n: v: lib.hasPrefix "github-runner-" n) config.systemd.services);
} 