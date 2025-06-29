#!/usr/bin/env bash
set -euo pipefail

echo "=== GitHub CI Runner 部署脚本 ==="
echo

# 检查是否在NixOS系统上
if [[ ! -f /etc/nixos/configuration.nix ]]; then
    echo "警告: 当前不在NixOS系统上"
    echo "你需要在NixOS系统上运行此配置"
    echo
    echo "如果你使用的是其他Linux发行版，可以:"
    echo "1. 安装NixOS虚拟机"
    echo "2. 或使用Docker容器运行NixOS"
    echo "3. 或在云服务器上安装NixOS"
    exit 1
fi

echo "1. 检查flake配置..."
nix flake check

echo "2. 预览将要部署的配置..."
nix build .#nixosConfigurations.nixos-ci.config.system.build.toplevel --dry-run

echo "3. 部署配置..."
echo "注意: 这将修改系统配置，请确认继续"
read -p "确认部署? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo nixos-rebuild switch --flake .#nixos-ci
    echo "部署完成!"
    echo
    echo "现在可以检查GitHub仓库设置页面查看runner状态:"
    echo "https://github.com/jiaqiwang969/nixos-ci/settings/actions/runners"
else
    echo "部署已取消"
fi