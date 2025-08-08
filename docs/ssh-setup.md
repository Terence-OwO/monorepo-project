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

### 测试SSH连接

使用项目提供的SSH连接测试工具：

```bash
# 使用默认配置文件
./scripts/test-ssh-connection.sh

# 使用自定义配置文件
./scripts/test-ssh-connection.sh my-deployment.env

# 使用环境变量
export SERVER_HOST="your-server.com"
export SERVER_USER="deploy"
export SSH_KEY="$(cat ~/.ssh/deploy_key)"
./scripts/test-ssh-connection.sh
```

测试工具会执行以下检查：

- 基本SSH连接测试
- 权限和命令执行测试
- 文件传输（SCP）测试
- 部署目录权限测试

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

1. **Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password)**
   - **问题原因**: SSH认证失败，所有认证方式都被拒绝
   - **解决方案**:
     - 检查私钥格式是否正确（确保包含完整的BEGIN/END标记）
     - 确认公钥已正确添加到服务器的 `~/.ssh/authorized_keys`
     - 检查服务器上的文件权限：
       ```bash
       chmod 700 ~/.ssh
       chmod 600 ~/.ssh/authorized_keys
       ```
     - 验证SSH用户名是否正确
     - 确保服务器SSH配置允许公钥认证：
       ```bash
       # /etc/ssh/sshd_config
       PubkeyAuthentication yes
       AuthorizedKeysFile .ssh/authorized_keys
       ```

2. **Host key verification failed**
   - 使用 `get-server-fingerprint.sh` 获取正确的主机密钥
   - 检查 `KNOWN_HOSTS` 配置是否正确

3. **Connection refused / Connection timed out**
   - 检查服务器IP/域名是否正确
   - 确认SSH服务是否运行
   - 检查防火墙设置和端口是否正确
   - 验证网络连接是否正常

4. **SSH key format errors**
   - 确保私钥是完整的，包含正确的头尾标记
   - 检查私钥是否有额外的空格或换行符
   - 确认密钥类型与服务器支持的格式匹配

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
- `scripts/test-ssh-connection.sh` - SSH连接测试工具
- `scripts/deploy.sh` - 部署脚本（已升级为SCP部署方式）
- `.github/workflows/cd.yml` - CD工作流（已优化为SCP部署）
- `deployment.env.example` - 部署配置示例
- `docs/ssh-setup.md` - SSH配置完整指南
- `docs/scp-deployment.md` - SCP部署方式详细指南

## 快速问题解决

### 当前遇到的错误: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password)

这个错误表明SSH认证完全失败。请按以下步骤操作：

1. **立即测试SSH连接**:

   ```bash
   ./scripts/test-ssh-connection.sh
   ```

2. **检查关键配置**:

   ```bash
   # 检查GitHub Secrets是否正确设置
   # - SERVER_HOST
   # - SERVER_USER
   # - SERVER_SSH_KEY

   # 检查服务器上的公钥
   ssh user@server "cat ~/.ssh/authorized_keys"

   # 检查服务器SSH配置
   ssh user@server "sudo cat /etc/ssh/sshd_config | grep -E '(PubkeyAuthentication|AuthorizedKeysFile)'"
   ```

3. **如果仍然失败，请检查**:
   - SSH私钥格式是否正确（完整的BEGIN/END标记）
   - 公钥是否正确添加到服务器
   - 服务器SSH服务是否正常运行
   - 网络连接是否正常

4. **使用新的SCP部署方式**:
   - 已升级为SCP部署方式，减少了SSH会话复杂性
   - 详细指南请参考：`docs/scp-deployment.md`
   - SCP部署对SSH认证要求更简单，可能解决当前认证问题
