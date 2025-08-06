# CI/CD 快速上手指南

## 🚀 30 分钟完成 CI/CD 配置

### 第一步：准备服务器（5分钟）

1. **购买云服务器**（如阿里云、腾讯云、AWS等）
   - 推荐配置：2核4G，Ubuntu 20.04+
   - 确保有公网IP

2. **初始化服务器**

   ```bash
   # 连接服务器
   ssh root@your-server-ip

   # 下载并运行初始化脚本
   curl -sSL https://raw.githubusercontent.com/your-username/monorepo-project/main/scripts/setup-server.sh | bash

   # 或者手动运行
   wget https://raw.githubusercontent.com/your-username/monorepo-project/main/scripts/setup-server.sh
   chmod +x setup-server.sh
   ./setup-server.sh
   ```

### 第二步：配置 SSH 密钥（5分钟）

1. **生成 SSH 密钥**（如果还没有）

   ```bash
   # 在本地机器上运行
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```

2. **添加公钥到服务器**

   ```bash
   # 方法1：使用 ssh-copy-id
   ssh-copy-id deploy@your-server-ip

   # 方法2：手动复制
   cat ~/.ssh/id_rsa.pub | ssh root@your-server-ip "mkdir -p /home/deploy/.ssh && cat >> /home/deploy/.ssh/authorized_keys && chown -R deploy:deploy /home/deploy/.ssh && chmod 600 /home/deploy/.ssh/authorized_keys"
   ```

3. **测试连接**
   ```bash
   ssh deploy@your-server-ip
   ```

### 第三步：配置 GitHub Secrets（5分钟）

1. **进入 GitHub 仓库设置**
   - 打开你的 GitHub 仓库
   - 点击 `Settings` > `Secrets and variables` > `Actions`

2. **添加必需的 Secrets**

   ```
   SERVER_HOST = your-server-ip
   SERVER_USER = deploy
   SERVER_SSH_KEY = <复制你的私钥内容>
   ```

   获取私钥内容：

   ```bash
   cat ~/.ssh/id_rsa
   ```

3. **添加可选的 Secrets**
   ```
   APP_URL = http://your-server-ip  # 用于健康检查
   DEPLOY_PATH = /var/www/admin-system  # 部署路径
   ```

### 第四步：推送代码触发部署（5分钟）

1. **确保代码在 GitHub 上**

   ```bash
   git add .
   git commit -m "feat: add CI/CD configuration"
   git push origin main
   ```

2. **查看工作流执行**
   - 进入 GitHub 仓库的 `Actions` 标签
   - 可以看到 CI Pipeline 自动运行
   - CI 完成后会自动触发 CD Pipeline

3. **验证部署**

   ```bash
   # 访问服务器查看部署结果
   curl http://your-server-ip/health

   # 查看部署目录
   ssh deploy@your-server-ip "ls -la /var/www/admin-system/"
   ```

### 第五步：测试增量部署（10分钟）

1. **修改 UI 组件**

   ```bash
   # 修改 packages/ui-components/src/components/MonButton/MonButton.vue
   # 添加一些样式或文本变更

   git add .
   git commit -m "feat: update button component"
   git push origin main
   ```

2. **观察增量构建**
   - 查看 GitHub Actions 日志
   - 只有 `ui-components` 和 `admin-system` 会被构建
   - 其他包会跳过构建

3. **修改后台系统**

   ```bash
   # 修改 apps/admin-system/src/views/dashboard/index.vue
   # 更改页面内容

   git add .
   git commit -m "feat: update dashboard"
   git push origin main
   ```

4. **观察变更检测**
   - 只有 `admin-system` 会被构建和部署
   - `ui-components` 会跳过构建

## 🛠️ 高级配置

### 多环境部署

1. **创建 staging 环境**

   ```bash
   # 在 GitHub 仓库设置中创建 Environment
   # Settings > Environments > New environment
   # 名称：staging
   ```

2. **配置不同的 Secrets**

   ```
   # Production 环境
   SERVER_HOST = your-prod-server-ip

   # Staging 环境
   SERVER_HOST = your-staging-server-ip
   ```

3. **使用手动部署**
   - 进入 `Actions` 标签
   - 选择 `Manual Deploy` 工作流
   - 点击 `Run workflow`
   - 选择环境和服务

### 通知集成

1. **Slack 通知**

   ```yaml
   # 在 .github/workflows/cd.yml 中添加
   - name: Send Slack Notification
     uses: 8398a7/action-slack@v3
     with:
       status: ${{ job.status }}
       webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
   ```

2. **钉钉通知**
   ```yaml
   - name: Send DingTalk Notification
     uses: zcong1993/actions-ding@master
     with:
       dingToken: ${{ secrets.DING_TOKEN }}
       body: |
         {
           "msgtype": "text",
           "text": {
             "content": "部署完成: ${{ github.repository }}"
           }
         }
   ```

### 性能监控

1. **添加应用监控**

   ```javascript
   // 在应用中添加性能监控
   if (process.env.NODE_ENV === "production") {
     // 添加 Sentry、监控宝等监控服务
   }
   ```

2. **服务器监控**

   ```bash
   # 安装监控工具
   sudo apt install htop iotop nethogs

   # 查看系统资源
   htop           # CPU和内存
   iotop          # 磁盘IO
   nethogs        # 网络使用
   ```

## 🔧 常见问题解决

### 1. SSH 连接失败

```bash
# 检查SSH配置
ssh -vvv deploy@your-server-ip

# 常见解决方法：
# 1. 检查防火墙设置
sudo ufw status

# 2. 检查SSH服务状态
sudo systemctl status ssh

# 3. 检查密钥权限
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### 2. 部署失败

```bash
# 查看部署日志
ssh deploy@your-server-ip "tail -f /var/log/nginx/error.log"

# 检查磁盘空间
df -h

# 检查进程
ps aux | grep nginx
```

### 3. 健康检查失败

```bash
# 测试端点
curl -I http://your-server-ip/health

# 检查端口占用
netstat -tlnp | grep :80

# 重启服务
sudo systemctl restart nginx
```

### 4. 构建缓存问题

```bash
# 清理本地缓存
pnpm store prune

# 清理 Turbo 缓存
pnpm turbo clean

# 强制重新构建
pnpm build --force
```

## 📊 监控面板

推荐安装简单的监控面板：

### Netdata（轻量级监控）

```bash
# 安装 Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# 访问监控面板
# http://your-server-ip:19999
```

### PM2 Monit（Node.js 应用监控）

```bash
# 安装 PM2
npm install -g pm2

# 如果使用 PM2 管理 Node.js 应用
pm2 monit
```

## 🎯 最佳实践

### 1. 分支策略

```
main (生产环境)
  ↑
develop (开发环境)
  ↑
feature/* (功能分支)
```

### 2. 提交规范

```bash
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 构建配置
```

### 3. 版本管理

```bash
# 使用语义化版本
git tag v1.0.0
git push origin v1.0.0

# 自动生成变更日志
npm install -g conventional-changelog-cli
conventional-changelog -p angular -i CHANGELOG.md -s
```

通过以上步骤，你的 monorepo 项目现在拥有了完整的 CI/CD 流程！
