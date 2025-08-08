# GitHub Secrets 配置指南

## 需要配置的 Secrets

在 GitHub 仓库中需要配置以下 4 个 Secrets：

### 1. SSH_PRIVATE_KEY

**描述**: 用于连接服务器的 SSH 私钥  
**获取方式**:

1. 在本地生成 SSH 密钥对（如果还没有）：
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```
2. 将公钥添加到服务器的 `~/.ssh/authorized_keys` 文件中：

   ```bash
   # 复制公钥内容
   cat ~/.ssh/id_rsa.pub

   # 在服务器上添加公钥
   ssh root@106.15.55.89
   echo "你的公钥内容" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. 复制私钥内容作为 Secret 值：
   ```bash
   cat ~/.ssh/id_rsa
   ```

### 2. SSH_USER

**描述**: 服务器登录用户名  
**值**: `root`

### 3. SERVER_HOST

**描述**: 服务器公网IP地址  
**值**: `106.15.55.89`

### 4. DEPLOY_PATH

**描述**: 服务器上的部署路径  
**值**: `/var/www/admin-system`

## 在 GitHub 上配置 Secrets 的详细步骤

### 方法1: 通过仓库设置页面

1. **进入仓库**: 打开你的 GitHub 仓库页面

2. **进入设置**: 点击仓库页面顶部的 "Settings" 选项卡

3. **找到 Secrets**: 在左侧菜单中找到 "Security" 部分，点击 "Secrets and variables"

4. **选择 Actions**: 点击 "Actions" 标签页

5. **添加 Secret**:
   - 点击 "New repository secret" 按钮
   - 在 "Name" 字段输入 Secret 名称（如 `SSH_PRIVATE_KEY`）
   - 在 "Secret" 字段粘贴对应的值
   - 点击 "Add secret" 保存

6. **重复步骤5** 为每个 Secret 添加配置

### 方法2: 通过直接链接（更快捷）

访问以下链接直接进入 Secrets 配置页面：

```
https://github.com/你的用户名/你的仓库名/settings/secrets/actions
```

## 配置完成后的验证

配置完成后，你应该能在 Secrets 页面看到 4 个已配置的 Secrets：

- ✅ SSH_PRIVATE_KEY
- ✅ SSH_USER
- ✅ SERVER_HOST
- ✅ DEPLOY_PATH

**注意**: Secret 的值在保存后无法查看，只能重新编辑覆盖。

## 服务器端准备工作

在服务器上确保以下配置：

1. **创建部署目录**：

   ```bash
   sudo mkdir -p /var/www/admin-system
   sudo chown -R www-data:www-data /var/www/admin-system
   ```

2. **确保 SSH 服务正常**：

   ```bash
   sudo systemctl status ssh
   ```

3. **配置防火墙**（如果有）：
   ```bash
   sudo ufw allow ssh
   ```

## 工作流触发方式

### 自动触发

- 推送代码到 `master` 分支
- 创建 Pull Request 到 `master` 分支

### 手动触发

1. 进入 GitHub 仓库的 "Actions" 页面
2. 选择 "CI/CD Pipeline" 工作流
3. 点击 "Run workflow" 按钮
4. 选择是否 "强制构建所有包"
5. 点击绿色的 "Run workflow" 按钮

## 注意事项

- SSH 私钥必须是完整的，包括 `-----BEGIN OPENSSH PRIVATE KEY-----` 和 `-----END OPENSSH PRIVATE KEY-----`
- 确保服务器的 SSH 端口是 22（默认），如果是其他端口需要修改工作流配置
- 部署过程会自动创建备份，最多保留最近 5 个备份
- 只有推送到 `master` 分支才会触发部署
