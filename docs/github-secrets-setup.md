# GitHub Secrets 配置指南

## 需要配置的 Secrets

在 GitHub 仓库中需要配置以下 3-4 个 Secrets（其中 DEPLOY_BASE_PATH 是可选的）：

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

### 4. DEPLOY_BASE_PATH (可选)

**描述**: 服务器上的基础部署路径，应用会部署到 `{DEPLOY_BASE_PATH}/{应用名称}` 目录下  
**默认值**: `/var/www` (如果不设置此Secret，将使用默认值)  
**示例**:

- 如果设置为 `/var/www`，则 `admin-system` 会部署到 `/var/www/admin-system`
- 如果设置为 `/home/websites`，则 `admin-system` 会部署到 `/home/websites/admin-system`

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

配置完成后，你应该能在 Secrets 页面看到以下已配置的 Secrets：

**必需的 Secrets**：

- ✅ SSH_PRIVATE_KEY
- ✅ SSH_USER
- ✅ SERVER_HOST

**可选的 Secrets**：

- ✅ DEPLOY_BASE_PATH (不设置则默认使用 `/var/www`)

**注意**: Secret 的值在保存后无法查看，只能重新编辑覆盖。

## 服务器端准备工作

在服务器上确保以下配置：

1. **创建基础部署目录**：

   ```bash
   # 创建基础目录（如果使用默认的 /var/www）
   sudo mkdir -p /var/www

   # 或创建自定义目录（如果设置了 DEPLOY_BASE_PATH）
   # sudo mkdir -p /your/custom/path

   # 设置适当的权限
   sudo chown -R root:root /var/www
   sudo chmod 755 /var/www
   ```

2. **应用目录会自动创建**：
   工作流会自动为每个应用创建对应的子目录：
   - `admin-system` → `/var/www/admin-system`
   - `admin-system-2` → `/var/www/admin-system-2`
   - 其他apps中的应用 → `/var/www/{应用名称}`

3. **确保 SSH 服务正常**：

   ```bash
   sudo systemctl status ssh
   ```

4. **配置防火墙**（如果有）：
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
- 工作流会自动检测 `apps/` 目录下的变更，只构建和部署有变化的应用
- 部署路径会根据应用名称动态生成：`{DEPLOY_BASE_PATH}/{应用名称}`

## 🎯 动态部署特性

### 智能变更检测

- 自动扫描 `apps/` 目录下的所有应用
- 只有当应用代码或 `ui-components` 有变更时才会构建该应用
- 支持同时构建和部署多个有变更的应用

### 动态部署路径

- **admin-system** → `/var/www/admin-system`
- **admin-system-2** → `/var/www/admin-system-2`
- **新应用** → `/var/www/{应用名称}`

### 示例部署结果

```
/var/www/
├── admin-system/          # 管理系统
│   ├── index.html
│   ├── assets/
│   └── ...
├── admin-system-2/        # 第二个管理系统
│   ├── index.html
│   ├── assets/
│   └── ...
└── your-new-app/         # 未来的新应用
    ├── index.html
    ├── assets/
    └── ...
```
