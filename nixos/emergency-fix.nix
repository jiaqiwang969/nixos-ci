# 紧急修复配置 - 确保基本登录功能
{ config, lib, pkgs, ... }:

{
  # 强制启用基本的 getty 服务
  systemd.services."getty@tty1" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "idle";
      Restart = "always";
      RestartSec = "0";
    };
  };

  systemd.services."getty@tty2" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };

  # 确保 multi-user.target 正确配置
  systemd.targets.multi-user.wantedBy = [ "default.target" ];
  
  # 禁用可能导致问题的自动登录
  services.getty.autologinUser = lib.mkForce null;
  
  # 简化启动参数
  boot.kernelParams = lib.mkForce [ "console=tty1" ];
  
  # 确保基本的系统服务
  systemd.services.systemd-user-sessions.enable = true;
} 