# SCP 部署方式指南

## 概述

SCP（Secure Copy Protocol）部署方式是一种简化的部署策略，通过文件传输而非复杂的远程命令执行来完成应用部署。这种方式具有以下优势：

- **简化复杂性**：减少了SSH会话的复杂性，避免了长时间的远程命令执行
- **更好的错误处理**：每个步骤都可以独立验证和处理错误
- **减少认证问题**：相比复杂的SSH脚本执行，SCP传输更稳定
- **更好的日志**：每个操作步骤都有清晰的日志输出

## 部署流程

### 1. 本地构建和打包

```
构建应用 → 创建部署包 → 准备部署文件
```

### 2. SCP文件传输

```
上传构建产物 → 上传部署脚本 → 创建远程临时目录
```

### 3. 远程执行部署

```
执行部署脚本 → 创建版本目录 → 更新软链接 → 重启服务
```

### 4. 清理和验证

```
清理临时文件 → 健康检查 → 完成部署
```

## 部署方式对比

| 特性           | SSH远程执行 | SCP部署 | rsync部署 |
| -------------- | ----------- | ------- | --------- |
| 复杂性         | 高          | 中      | 低        |
| 错误处理       | 困难        | 较好    | 简单      |
| 网络稳定性要求 | 高          | 中      | 中        |
| 调试难度       | 高          | 中      | 低        |
| 支持断点续传   | 否          | 否      | 是        |

## 使用方法

### 本地部署脚本

```bash
# 设置环境变量
export SERVER_HOST="your-server.com"
export SERVER_USER="deploy"
export DEPLOY_PATH="/var/www/admin-system"

# 运行SCP部署
./scripts/deploy.sh production admin-system
```

### GitHub Actions

SCP部署已集成到CD工作流中，当推送到main分支时会自动触发。

#### 必需的GitHub Secrets

| Secret名称       | 描述                   | 示例                                     |
| ---------------- | ---------------------- | ---------------------------------------- |
| `SERVER_HOST`    | 服务器主机名或IP       | `192.168.1.100`                          |
| `SERVER_USER`    | SSH用户名              | `deploy`                                 |
| `SERVER_SSH_KEY` | SSH私钥                | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `SERVER_PORT`    | SSH端口（可选）        | `22`                                     |
| `KNOWN_HOSTS`    | 服务器主机密钥（推荐） | 使用脚本获取                             |

## 部署脚本工作原理

### 1. 准备阶段

```bash
# 创建临时目录
temp_dir="deployment-temp-${TIMESTAMP}"
mkdir -p "$temp_dir"

# 解压构建产物
tar -xzf "deployment-packages/admin-system-${TIMESTAMP}.tar.gz"
```

### 2. SCP传输阶段

```bash
# 创建远程临时目录
remote_temp_dir="/tmp/deploy-${TIMESTAMP}"
ssh "${SERVER_HOST}" "mkdir -p ${remote_temp_dir}"

# 上传构建产物
scp -r dist "${SERVER_HOST}:${remote_temp_dir}/"

# 上传部署脚本
scp deploy_script.sh "${SERVER_HOST}:${remote_temp_dir}/"
```

### 3. 远程执行阶段

```bash
# 执行部署
ssh "${SERVER_HOST}" "cd ${remote_temp_dir} && bash deploy_script.sh ${TIMESTAMP} ${DEPLOY_PATH}"
```

### 4. 清理阶段

```bash
# 清理远程临时文件
ssh "${SERVER_HOST}" "rm -rf ${remote_temp_dir}"

# 清理本地临时目录
rm -rf "$temp_dir"
```

## 远程部署脚本

SCP部署会在服务器上执行以下脚本：

```bash
#!/bin/bash
set -e

TIMESTAMP="$1"
DEPLOY_PATH="$2"

# 创建版本目录
mkdir -p "${DEPLOY_PATH}/releases/${TIMESTAMP}"

# 移动文件到版本目录
mv ./dist/* "${DEPLOY_PATH}/releases/${TIMESTAMP}/"

# 创建软链接到当前版本
ln -sfn "${DEPLOY_PATH}/releases/${TIMESTAMP}" "${DEPLOY_PATH}/current"

# 重启Web服务器
sudo systemctl reload nginx || true

# 清理旧版本（保留最近5个）
cd "${DEPLOY_PATH}/releases"
ls -t | tail -n +6 | xargs rm -rf 2>/dev/null || true
```

## 服务器目录结构

部署后的服务器目录结构：

```
/var/www/admin-system/
├── current -> releases/latest-timestamp/
└── releases/
    ├── 20240101_120000/
    ├── 20240101_130000/
    ├── 20240101_140000/
    └── latest-timestamp/
        ├── index.html
        ├── assets/
        └── ...
```

## 测试SCP部署

### 1. 测试SSH连接

```bash
./scripts/test-ssh-connection.sh
```

### 2. 测试SCP传输

```bash
# 创建测试文件
echo "SCP测试文件" > test.txt

# 测试上传
scp test.txt user@server:/tmp/

# 测试下载
scp user@server:/tmp/test.txt ./test_download.txt

# 清理测试文件
rm test.txt test_download.txt
ssh user@server "rm /tmp/test.txt"
```

### 3. 完整部署测试

```bash
# 确保已构建项目
pnpm --filter @monorepo-project/admin-system build

# 运行部署脚本
./scripts/deploy.sh production admin-system
```

## 故障排除

### 常见问题

1. **SCP传输失败**

   ```bash
   # 检查SSH连接
   ssh user@server "echo 'connection test'"

   # 检查目标目录权限
   ssh user@server "ls -la /tmp/"

   # 测试小文件传输
   echo "test" | ssh user@server "cat > /tmp/scp_test.txt"
   ```

2. **部署脚本执行失败**

   ```bash
   # 检查远程脚本权限
   ssh user@server "ls -la /tmp/deploy-*/deploy_script.sh"

   # 手动执行脚本查看错误
   ssh user@server "cd /tmp/deploy-* && bash -x deploy_script.sh"
   ```

3. **文件权限问题**

   ```bash
   # 检查部署目录权限
   ssh user@server "ls -la /var/www/"

   # 确保用户有写权限
   ssh user@server "touch /var/www/admin-system/test && rm /var/www/admin-system/test"
   ```

### 调试技巧

1. **启用详细日志**

   ```bash
   # 在部署脚本中添加调试输出
   set -x  # 启用脚本调试模式
   ```

2. **保留临时文件进行调试**

   ```bash
   # 注释掉清理临时文件的代码
   # rm -rf "$temp_dir"
   # ssh "${SERVER_HOST}" "rm -rf ${remote_temp_dir}"
   ```

3. **分步执行**
   ```bash
   # 单独执行每个步骤
   scp -r dist user@server:/tmp/debug/
   ssh user@server "ls -la /tmp/debug/"
   ```

## 性能优化

### 1. SCP传输优化

```bash
# 使用压缩传输
scp -C file user@server:/path/

# 并行传输多个文件
scp -r -o "ConnectionMultiplexing=yes" files/ user@server:/path/
```

### 2. 减少传输数据

```bash
# 压缩文件后传输
tar -czf files.tar.gz files/
scp files.tar.gz user@server:/path/
ssh user@server "cd /path && tar -xzf files.tar.gz && rm files.tar.gz"
```

### 3. 复用SSH连接

```bash
# 在SSH config中配置连接复用
Host server
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist 10m
```

## 回滚支持

SCP部署支持快速回滚到之前的版本：

```bash
# 查看可用版本
ssh user@server "ls -la /var/www/admin-system/releases/"

# 回滚到指定版本
./scripts/deploy.sh rollback
```

## 监控和日志

### 部署日志

```bash
# 查看部署日志
tail -f /var/log/deploy.log

# 查看Nginx访问日志
tail -f /var/log/nginx/access.log
```

### 应用监控

```bash
# 检查应用状态
curl -I http://your-domain.com

# 检查进程状态
ssh user@server "systemctl status nginx"
```

## 相关文件

- `scripts/deploy.sh` - 主部署脚本
- `scripts/test-ssh-connection.sh` - SSH连接测试工具
- `.github/workflows/cd.yml` - CI/CD工作流
- `docs/ssh-setup.md` - SSH配置指南
