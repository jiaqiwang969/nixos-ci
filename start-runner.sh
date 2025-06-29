#!/usr/bin/env bash
# 手动启动 GitHub Runner 的脚本

echo "=== GitHub Runner 启动脚本 ==="
echo

# 检查 token 文件
if [ ! -f "/run/agenix/github-nix-ci/jiaqiwang969.token.age" ]; then
    echo "错误: Token 文件不存在"
    echo "请确保已正确配置 agenix secrets"
    exit 1
fi

# 检查网络连接
echo "检查网络连接..."
if ! ping -c 1 github.com &> /dev/null; then
    echo "错误: 无法连接到 GitHub"
    exit 1
fi

echo "网络连接正常"

# 启动 runner 服务
echo "启动 GitHub Runner 服务..."
sudo systemctl start github-runner-nixos-ci-jiaqiwang969-nixos-ci-01.service

# 检查状态
echo
echo "检查服务状态..."
sudo systemctl status github-runner-nixos-ci-jiaqiwang969-nixos-ci-01.service

echo
echo "查看日志 (最后 20 行):"
sudo journalctl -u github-runner-nixos-ci-jiaqiwang969-nixos-ci-01.service -n 20 