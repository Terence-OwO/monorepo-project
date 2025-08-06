# CI/CD 流程配置指南

## 概述

本项目配置了完整的 CI/CD 流程，支持 monorepo 架构下的增量构建和自动部署。主要特性：

- 🚀 基于变更检测的增量构建
- 📦 自动化打包和部署
- 🔄 支持回滚和健康检查
- 🎯 多环境部署支持
- 📊 构建缓存优化

## 工作流概览

### 1. CI Pipeline (`.github/workflows/ci.yml`)

**触发条件：**

- Push 到 `main`、`develop` 分支
- 针对 `main`、`develop` 分支的 Pull Request

**主要步骤：**

1. **变更检测** - 检测哪些包发生了变更
2. **依赖安装** - 缓存 node_modules 和 pnpm store
3. **代码检查** - 运行 ESLint 和类型检查
4. **测试执行** - 运行单元测试
5. **增量构建** - 只构建变更的包

### 2. CD Pipeline (`.github/workflows/cd.yml`)

**触发条件：**

- Push 到 `main` 分支
- CI Pipeline 成功完成后

**主要步骤：**

1. **变更检测** - 确定需要部署的服务
2. **构建部署包** - 创建生产环境构建
3. **服务器部署** - 上传并部署到服务器
4. **健康检查** - 验证部署是否成功
5. **通知反馈** - 发送部署结果通知

### 3. 手动部署 (`.github/workflows/manual-deploy.yml`)

**触发条件：**

- 手动触发（workflow_dispatch）

**配置选项：**

- 环境选择：production / staging
- 服务选择：all / ui-components / admin-system
- 跳过测试选项

## 增量构建原理

### 变更检测

使用 `dorny/paths-filter` action 检测文件变更：

```yaml
filters: |
  ui-components:
    - 'packages/ui-components/**'
  admin-system:
    - 'apps/admin-system/**'
    - 'packages/ui-components/**'  # UI组件变更也影响admin系统
```

### 构建依赖关系

通过 Turbo 配置构建依赖：

```json
{
  "build": {
    "dependsOn": ["^build"], // 依赖包先构建
    "outputs": ["dist/**"]
  }
}
```

### 缓存策略

- **pnpm store 缓存** - 依赖包下载缓存
- **node_modules 缓存** - 已安装依赖缓存
- **Turbo 缓存** - 构建结果缓存

## 配置步骤

### 1. GitHub Secrets 配置

在 GitHub 仓库的 `Settings > Secrets and variables > Actions` 中添加：

#### 必需的 Secrets：

| 名称             | 描述         | 示例                                     |
| ---------------- | ------------ | ---------------------------------------- |
| `SERVER_HOST`    | 服务器地址   | `123.456.789.0`                          |
| `SERVER_USER`    | 服务器用户名 | `deploy`                                 |
| `SERVER_SSH_KEY` | SSH 私钥     | `-----BEGIN OPENSSH PRIVATE KEY-----...` |

#### 可选的 Secrets：

| 名称           | 描述        | 默认值                  |
| -------------- | ----------- | ----------------------- |
| `SERVER_PORT`  | SSH 端口    | `22`                    |
| `DEPLOY_PATH`  | 部署路径    | `/var/www/admin-system` |
| `APP_URL`      | 应用地址    | 用于健康检查            |
| `GITHUB_TOKEN` | GitHub 令牌 | 自动提供                |

### 2. 服务器准备

#### 创建部署用户

```bash
# 创建部署用户
sudo useradd -m -s /bin/bash deploy

# 创建 SSH 目录
sudo mkdir -p /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh

# 添加公钥到 authorized_keys
sudo tee /home/deploy/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2E... # 你的公钥
EOF

sudo chmod 600 /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh
```

#### 配置 sudo 权限

```bash
sudo tee /etc/sudoers.d/deploy << EOF
deploy ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
deploy ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
EOF
```

#### 创建部署目录

```bash
sudo mkdir -p /var/www/admin-system/{releases,shared}
sudo chown -R deploy:deploy /var/www/admin-system
```

### 3. Nginx 配置

```nginx
server {
    listen 80;
    server_name your-domain.com;

    root /var/www/admin-system/current/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # 健康检查端点
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # 静态资源缓存
    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## 本地开发脚本

### 部署脚本使用

```bash
# 部署所有服务到生产环境
./scripts/deploy.sh production all

# 只部署 admin-system
./scripts/deploy.sh production admin-system

# 回滚到上一个版本
./scripts/deploy.sh rollback
```

### 健康检查脚本

```bash
# 检查本地服务
./scripts/health-check.sh http://localhost:3000

# 检查生产服务
./scripts/health-check.sh https://your-domain.com
```

## 工作流程示例

### 日常开发流程

1. **功能开发**

   ```bash
   git checkout -b feature/new-component
   # 开发新功能
   git commit -m "feat: add new component"
   git push origin feature/new-component
   ```

2. **创建 PR**
   - GitHub 自动触发 CI Pipeline
   - 只检查和构建变更的包
   - 代码审查通过后合并

3. **自动部署**
   - 合并到 main 分支后自动触发 CD Pipeline
   - 只部署有变更的服务
   - 自动执行健康检查

### 紧急修复流程

1. **快速修复**

   ```bash
   git checkout -b hotfix/critical-bug
   # 修复问题
   git commit -m "fix: critical bug"
   git push origin hotfix/critical-bug
   ```

2. **快速部署**
   - 使用手动部署工作流
   - 可选择跳过测试（紧急情况）
   - 立即部署到生产环境

3. **回滚（如需要）**
   ```bash
   ./scripts/deploy.sh rollback
   ```

## 监控和通知

### 部署状态监控

- GitHub Actions 提供详细的部署日志
- 每个步骤的执行状态和耗时
- 构建产物的存储和下载

### 失败处理

- 自动检测部署失败
- 提供回滚选项
- 详细的错误信息和日志

### 扩展通知（可选）

可以添加以下通知集成：

```yaml
# Slack 通知
- name: Send Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}

# 邮件通知
- name: Send Email
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    to: team@company.com
    subject: Deployment Status
```

## 性能优化

### 构建优化

- **并行构建** - 独立包并行构建
- **增量构建** - 只构建变更的包
- **缓存复用** - 多层缓存策略

### 部署优化

- **零停机部署** - 蓝绿部署策略
- **分批部署** - 大型应用分批更新
- **健康检查** - 确保部署成功

## 故障排除

### 常见问题

1. **SSH 连接失败**
   - 检查 SSH 密钥配置
   - 验证服务器网络连接
   - 确认用户权限

2. **构建失败**
   - 检查依赖版本兼容性
   - 验证环境变量配置
   - 查看详细错误日志

3. **健康检查失败**
   - 确认应用启动时间
   - 检查端口和路径配置
   - 验证服务器防火墙设置

### 调试方法

1. **本地测试**

   ```bash
   # 本地运行部署脚本
   ./scripts/deploy.sh staging admin-system

   # 测试健康检查
   ./scripts/health-check.sh http://localhost:3000
   ```

2. **查看日志**
   - GitHub Actions 日志
   - 服务器应用日志
   - Nginx 访问日志

3. **手动验证**
   ```bash
   # SSH 到服务器检查
   ssh deploy@your-server
   ls -la /var/www/admin-system/
   ```

## 总结

通过以上配置，你的 monorepo 项目现在具备了：

- ✅ 自动化的 CI/CD 流程
- ✅ 基于变更的增量构建
- ✅ 零停机部署能力
- ✅ 完整的回滚机制
- ✅ 健康检查和监控
- ✅ 多环境支持

这套流程可以显著提高开发效率，减少手动操作错误，确保代码质量和部署稳定性。
