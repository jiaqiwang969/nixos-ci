# GitHub CI Runner 配置模块
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
} 