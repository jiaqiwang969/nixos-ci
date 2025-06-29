#!/usr/bin/env bash
set -euo pipefail

echo "=== GitHub CI Runner 诊断脚本 ==="
echo "时间: $(date)"
echo

# 检查是否在NixOS系统上
echo "1. 系统检查"
echo "============"
if [[ -f /etc/nixos/configuration.nix ]]; then
    echo "✓ 运行在NixOS系统上"
    echo "NixOS版本: $(nixos-version 2>/dev/null || echo '未知')"
else
    echo "✗ 不在NixOS系统上"
    echo "当前系统: $(uname -a)"
fi

echo "当前用户: $(whoami)"
echo "工作目录: $(pwd)"
echo

# 检查flake配置
echo "2. Flake配置检查"
echo "==============="
if [[ -f flake.nix ]]; then
    echo "✓ flake.nix存在"
    if nix flake check 2>/dev/null; then
        echo "✓ flake配置有效"
    else
        echo "✗ flake配置有问题"
        nix flake check 2>&1 | head -10
    fi
else
    echo "✗ flake.nix不存在"
fi
echo

# 检查runner配置
echo "3. Runner配置检查"
echo "=================="
if command -v nix >/dev/null 2>&1; then
    echo "检查生成的runner服务..."
    if nix eval .#nixosConfigurations.example.config.services.github-runners --json 2>/dev/null | jq -r 'keys[]' 2>/dev/null; then
        echo "✓ Runner配置已生成"
        echo "Runner名称:"
        nix eval .#nixosConfigurations.example.config.services.github-runners --json 2>/dev/null | jq -r 'keys[]' 2>/dev/null | sed 's/^/  - /'
    else
        echo "✗ 无法读取runner配置"
    fi
else
    echo "✗ nix命令不可用"
fi
echo

# 检查systemd服务
echo "4. Systemd服务检查"
echo "=================="
echo "GitHub runner服务:"
if systemctl list-units --all | grep -i github-runner; then
    echo "找到GitHub runner服务"
else
    echo "未找到GitHub runner服务"
fi

echo
echo "所有GitHub相关服务:"
systemctl list-units --all | grep -i github || echo "未找到GitHub相关服务"
echo

# 检查服务状态
echo "5. 服务状态详情"
echo "=============="
SERVICE_NAME="github-runner-nixos-jiaqiwang969-nixos-ci-01.service"
if systemctl list-units --all | grep -q "$SERVICE_NAME"; then
    echo "服务 $SERVICE_NAME 状态:"
    systemctl status "$SERVICE_NAME" --no-pager || true
    echo
    echo "最近日志:"
    journalctl -u "$SERVICE_NAME" --since "1 hour ago" --no-pager -n 20 || true
else
    echo "服务 $SERVICE_NAME 不存在"
fi
echo

# 检查secrets
echo "6. Secrets检查"
echo "============="
if [[ -d /run/agenix ]]; then
    echo "✓ agenix运行目录存在"
    echo "可用的secrets:"
    ls -la /run/agenix/ | grep github || echo "没有GitHub相关secrets"
else
    echo "✗ agenix运行目录不存在"
fi

if [[ -f secrets/github-nix-ci/jiaqiwang969.token.age ]]; then
    echo "✓ 本地token文件存在"
    echo "文件权限: $(ls -la secrets/github-nix-ci/jiaqiwang969.token.age)"
else
    echo "✗ 本地token文件不存在"
fi
echo

# 检查网络连接
echo "7. 网络连接检查"
echo "=============="
echo "测试GitHub API连接:"
if curl -s -I https://api.github.com | head -1; then
    echo "✓ 可以连接到GitHub API"
else
    echo "✗ 无法连接到GitHub API"
fi

echo
echo "测试仓库访问:"
REPO_URL="https://api.github.com/repos/jiaqiwang969/nixos-ci"
if curl -s "$REPO_URL" | head -1 | grep -q '"id"'; then
    echo "✓ 可以访问仓库API"
else
    echo "✗ 无法访问仓库API"
fi
echo

# 检查最近的系统重建
echo "8. 系统重建历史"
echo "=============="
echo "最近的nixos-rebuild日志:"
journalctl -u nixos-rebuild.service --since "2 hours ago" --no-pager -n 10 2>/dev/null || echo "没有找到最近的重建日志"
echo

# 检查用户和权限
echo "9. 用户和权限检查"
echo "================"
if getent passwd github-runner >/dev/null 2>&1; then
    echo "✓ github-runner用户存在"
    echo "用户信息: $(getent passwd github-runner)"
else
    echo "✗ github-runner用户不存在"
fi

if getent group github-runner >/dev/null 2>&1; then
    echo "✓ github-runner组存在"
else
    echo "✗ github-runner组不存在"
fi
echo

# 提供建议
echo "10. 排查建议"
echo "============"
echo "如果runner没有出现在GitHub上，请检查:"
echo "1. 确保nixos-rebuild switch成功完成"
echo "2. 检查GitHub token权限是否正确"
echo "3. 确认网络可以访问GitHub"
echo "4. 查看systemd服务日志获取详细错误信息"
echo
echo "诊断完成！"