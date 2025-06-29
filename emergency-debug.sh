#!/bin/bash
echo "=== 系统启动失败诊断 ==="
echo
echo "1. 检查失败的服务："
systemctl --failed

echo
echo "2. 查看系统日志（最后50行）："
journalctl -xb | tail -50

echo
echo "3. 检查挂载点："
mount | grep -E "sda|boot"

echo
echo "4. 检查 getty 服务状态："
systemctl status getty@tty1.service

echo
echo "5. 检查默认 target："
systemctl get-default

echo
echo "6. 查看启动目标依赖："
systemctl list-dependencies multi-user.target | grep -E "failed|getty"
