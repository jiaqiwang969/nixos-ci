# WJQ GitHub CI Runner 配置

这是基于 `github-nix-ci` 项目的个人CI runner配置。

## 配置概览

- **GitHub仓库**: `jiaqiwang969/nixos-ci`
- **架构**: `aarch64-linux`
- **Runner数量**: 1个
- **Runner名称**: `nixos-jiaqiwang969-nixos-ci-01`

## 文件结构

```
wjq-example/
├── flake.nix              # 主配置文件
├── flake.lock             # 锁定的依赖版本
├── secrets/
│   ├── secrets.nix        # agenix密钥配置
│   └── github-nix-ci/
│       └── jiaqiwang969.token.age  # 加密的GitHub token
├── .github/
│   └── workflows/
│       └── ci.yaml        # 示例CI workflow
├── deploy.sh              # 部署脚本
└── README.md              # 说明文档
```

## 部署步骤

### 1. 在NixOS系统上部署

```bash
# 运行部署脚本
./deploy.sh
```

或手动执行：

```bash
# 检查配置
nix flake check

# 部署到系统
sudo nixos-rebuild switch --flake .#example
```

### 2. 验证部署

部署成功后，访问 GitHub 仓库设置页面查看runner状态：
https://github.com/jiaqiwang969/nixos-ci/settings/actions/runners

你应该能看到一个名为 `nixos-jiaqiwang969-nixos-ci-01` 的runner处于在线状态。

### 3. 测试CI

将示例的 `.github/workflows/ci.yaml` 文件复制到你的 `jiaqiwang969/nixos-ci` 仓库中，然后推送代码触发CI构建。

## 配置说明

### flake.nix 关键配置

- `personalRunners`: 配置个人仓库的runner
- `nixpkgs.hostPlatform`: 设置为 `aarch64-linux`
- `age.secretsDir`: 指向secrets目录

### secrets管理

使用 agenix 管理敏感信息：
- GitHub Personal Access Token 存储在 `secrets/github-nix-ci/jiaqiwang969.token.age`
- 使用你的SSH公钥加密

### 自动标签

Runner会自动获得以下标签：
- `nixos` (hostname)
- `aarch64-linux` (支持的系统架构)

在workflow中可以使用 `runs-on: aarch64-linux` 来指定使用这个runner。

## 故障排除

### 常见问题

1. **Runner连接失败**
   - 检查GitHub token是否有效
   - 确认token有正确的权限（Repository permissions > Administration: Read and write）

2. **部署失败**
   - 确保在NixOS系统上运行
   - 检查flake配置语法是否正确

3. **CI构建失败**
   - 确认workflow中的 `runs-on` 标签正确
   - 检查runner是否在线

### 更新配置

修改配置后重新部署：

```bash
# 检查更改
nix flake check

# 重新部署
sudo nixos-rebuild switch --flake .#example
```

## 相关链接

- [github-nix-ci 项目](https://github.com/juspay/github-nix-ci)
- [GitHub Self-hosted Runners 文档](https://docs.github.com/en/actions/hosting-your-own-runners)
- [agenix 密钥管理](https://github.com/ryantm/agenix)