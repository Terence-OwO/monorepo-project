# SSH 配置指南

## 问题描述

在CI/CD部署过程中遇到以下错误：

- `Host key verification failed`
- `scp: Connection closed`

这些错误通常是由于SSH主机密钥验证失败导致的。

## 解决方案

### 方案一：配置 KNOWN_HOSTS（推荐）

这是最安全的解决方案，通过预先配置服务器的SSH主机密钥来避免验证失败。

#### 1. 获取服务器SSH指纹

使用项目提供的脚本获取服务器SSH指纹：

```bash
./scripts/get-server-fingerprint.sh your-server.com 22
```

#### 2. 配置GitHub Secrets

在GitHub仓库的 `Settings > Secrets and variables > Actions` 中添加：

- `KNOWN_HOSTS`: 从步骤1获取的SSH主机密钥

#### 3. 本地部署配置

如果使用本地部署脚本，在 `deployment.env` 文件中设置：

```bash
KNOWN_HOSTS="your-server-host-keys-here"
```

### 方案二：禁用严格主机密钥检查（不推荐生产环境）

如果无法预先获取服务器指纹，可以临时禁用严格主机密钥检查。

**注意：此方案存在安全风险，仅适用于测试环境。**

现有的脚本已经自动处理：如果没有设置 `KNOWN_HOSTS`，将自动禁用严格主机密钥检查。

## SSH密钥配置

### 生成SSH密钥对

如果还没有SSH密钥，可以生成一个：

```bash
# 生成新的SSH密钥对
ssh-keygen -t ed25519 -C "deploy@your-project" -f ~/.ssh/deploy_key

# 或使用RSA格式（如果服务器不支持ed25519）
ssh-keygen -t rsa -b 4096 -C "deploy@your-project" -f ~/.ssh/deploy_key
```

### 配置服务器

将公钥添加到服务器的authorized_keys：

```bash
# 复制公钥到服务器
ssh-copy-id -i ~/.ssh/deploy_key.pub user@your-server.com

# 或手动添加
cat ~/.ssh/deploy_key.pub | ssh user@your-server.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### GitHub Secrets配置

在GitHub仓库中配置以下Secrets：

| Secret名称       | 描述             | 示例                                     |
| ---------------- | ---------------- | ---------------------------------------- |
| `SERVER_HOST`    | 服务器主机名或IP | `192.168.1.100` 或 `example.com`         |
| `SERVER_USER`    | SSH用户名        | `deploy`                                 |
| `SERVER_SSH_KEY` | 私钥内容         | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `SERVER_PORT`    | SSH端口（可选）  | `22`                                     |
| `KNOWN_HOSTS`    | 服务器主机密钥   | 使用脚本获取                             |

## 验证配置

### 测试SSH连接

```bash
# 测试SSH连接
ssh -T user@your-server.com

# 如果使用自定义端口
ssh -T -p 2222 user@your-server.com
```

### 测试部署脚本

```bash
# 设置环境变量
export SERVER_HOST="your-server.com"
export SERVER_USER="deploy"
export DEPLOY_PATH="/var/www/admin-system"

# 运行部署脚本
./scripts/deploy.sh production admin-system
```

## 故障排除

### 常见错误

1. **Permission denied (publickey)**
   - 检查私钥是否正确
   - 确认公钥已添加到服务器
   - 检查SSH用户名是否正确

2. **Host key verification failed**
   - 使用 `get-server-fingerprint.sh` 获取正确的主机密钥
   - 检查 `KNOWN_HOSTS` 配置是否正确

3. **Connection refused**
   - 检查服务器IP/域名是否正确
   - 确认SSH服务是否运行
   - 检查防火墙设置

### 调试SSH连接

```bash
# 启用详细输出
ssh -v user@your-server.com

# 测试特定私钥
ssh -i ~/.ssh/deploy_key user@your-server.com

# 忽略known_hosts检查（仅用于调试）
ssh -o StrictHostKeyChecking=no user@your-server.com
```

## 安全建议

1. **使用专门的部署用户**
   - 创建专用的部署用户而不是使用root
   - 限制部署用户的权限

2. **定期轮换SSH密钥**
   - 定期更新SSH密钥对
   - 使用密钥管理服务

3. **监控SSH访问**
   - 启用SSH日志记录
   - 监控异常登录活动

4. **网络安全**
   - 使用VPN或跳板机
   - 限制SSH访问的IP范围

## 相关文件

- `scripts/get-server-fingerprint.sh` - 获取服务器SSH指纹
- `scripts/deploy.sh` - 部署脚本
- `.github/workflows/cd.yml` - CD工作流
- `deployment.env.example` - 部署配置示例
