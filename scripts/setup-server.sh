#!/bin/bash

# 服务器初始化脚本
# 用法: curl -sSL https://raw.githubusercontent.com/your-repo/main/scripts/setup-server.sh | bash
# 或者: ./scripts/setup-server.sh

set -e

echo "🚀 开始服务器初始化配置..."

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "请不要使用 root 用户运行此脚本"
        exit 1
    fi
}

# 更新系统包
update_system() {
    log_step "更新系统包..."
    sudo apt update && sudo apt upgrade -y
}

# 安装必要软件
install_dependencies() {
    log_step "安装必要软件..."
    sudo apt install -y \
        nginx \
        nodejs \
        npm \
        curl \
        git \
        unzip \
        htop \
        ufw
}

# 安装 Node.js 18
install_nodejs() {
    log_step "安装 Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # 验证安装
    node_version=$(node --version)
    npm_version=$(npm --version)
    log_info "Node.js 版本: $node_version"
    log_info "npm 版本: $npm_version"
}

# 安装 pnpm
install_pnpm() {
    log_step "安装 pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    source ~/.bashrc
    
    # 验证安装
    if command -v pnpm &> /dev/null; then
        pnpm_version=$(pnpm --version)
        log_info "pnpm 版本: $pnpm_version"
    else
        log_warn "pnpm 需要重新登录后才能使用"
    fi
}

# 创建部署用户
create_deploy_user() {
    log_step "创建部署用户..."
    
    # 检查用户是否已存在
    if id "deploy" &>/dev/null; then
        log_warn "用户 deploy 已存在，跳过创建"
    else
        sudo useradd -m -s /bin/bash deploy
        log_info "用户 deploy 创建成功"
    fi
    
    # 创建 SSH 目录
    sudo mkdir -p /home/deploy/.ssh
    sudo chmod 700 /home/deploy/.ssh
    sudo chown -R deploy:deploy /home/deploy/.ssh
    
    log_info "请将您的公钥添加到 /home/deploy/.ssh/authorized_keys"
}

# 配置 sudo 权限
setup_sudo() {
    log_step "配置 sudo 权限..."
    
    # 检查是否已配置
    if sudo test -f /etc/sudoers.d/deploy; then
        log_warn "sudo 权限已配置，跳过"
    else
        sudo tee /etc/sudoers.d/deploy > /dev/null << EOF
deploy ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
deploy ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
deploy ALL=(ALL) NOPASSWD: /bin/systemctl status nginx
EOF
        log_info "sudo 权限配置完成"
    fi
}

# 创建项目目录
create_project_dirs() {
    log_step "创建项目目录..."
    
    sudo mkdir -p /var/www/admin-system/{releases,shared,current}
    sudo chown -R deploy:deploy /var/www/admin-system
    sudo chmod -R 755 /var/www/admin-system
    
    log_info "项目目录创建完成: /var/www/admin-system"
}

# 配置 Nginx
setup_nginx() {
    log_step "配置 Nginx..."
    
    # 备份默认配置
    if [[ -f /etc/nginx/sites-available/default ]]; then
        sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
    fi
    
    # 创建站点配置
    sudo tee /etc/nginx/sites-available/admin-system > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;  # 替换为你的域名
    
    root /var/www/admin-system/current/dist;
    index index.html;
    
    # 主应用路由
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 健康检查端点
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # API 代理（如果需要）
    # location /api/ {
    #     proxy_pass http://localhost:8080;
    #     proxy_set_header Host $host;
    #     proxy_set_header X-Real-IP $remote_addr;
    #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto $scheme;
    # }
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options nosniff;
    }
    
    # 安全头部
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
EOF
    
    # 启用站点
    sudo ln -sf /etc/nginx/sites-available/admin-system /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # 测试配置
    if sudo nginx -t; then
        log_info "Nginx 配置测试通过"
        sudo systemctl restart nginx
        sudo systemctl enable nginx
        log_info "Nginx 服务已启动并设置为开机自启"
    else
        log_error "Nginx 配置测试失败"
        exit 1
    fi
}

# 配置防火墙
setup_firewall() {
    log_step "配置防火墙..."
    
    sudo ufw --force enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    
    log_info "防火墙配置完成"
    sudo ufw status
}

# 创建部署示例文件
create_deployment_example() {
    log_step "创建部署示例..."
    
    sudo mkdir -p /var/www/admin-system/current/dist
    sudo tee /var/www/admin-system/current/dist/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>部署成功</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            margin-top: 100px; 
            background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { color: #4CAF50; margin-bottom: 20px; }
        .status { margin: 20px 0; }
        .success { color: #4CAF50; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 服务器配置成功！</h1>
        <div class="status">
            <p class="success">✅ Nginx 运行正常</p>
            <p class="success">✅ 部署环境已准备就绪</p>
            <p class="success">✅ 等待应用部署...</p>
        </div>
        <p>服务器时间: <span id="time"></span></p>
    </div>
    
    <script>
        function updateTime() {
            document.getElementById('time').textContent = new Date().toLocaleString('zh-CN');
        }
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
EOF
    
    sudo chown -R deploy:deploy /var/www/admin-system/current
    log_info "部署示例页面已创建"
}

# 安装系统监控工具
install_monitoring() {
    log_step "安装系统监控工具..."
    
    # 安装基本监控工具
    sudo apt install -y htop iotop nethogs
    
    log_info "监控工具安装完成"
    log_info "  - htop: 进程监控"
    log_info "  - iotop: IO 监控" 
    log_info "  - nethogs: 网络监控"
}

# 显示配置信息
show_summary() {
    log_step "配置完成总结"
    
    echo ""
    echo "🎉 服务器初始化完成！"
    echo ""
    echo "📋 配置信息："
    echo "  - 部署用户: deploy"
    echo "  - 项目目录: /var/www/admin-system"
    echo "  - Nginx 配置: /etc/nginx/sites-available/admin-system"
    echo "  - 当前目录: /var/www/admin-system/current"
    echo ""
    echo "🔑 后续步骤："
    echo "  1. 将 SSH 公钥添加到 /home/deploy/.ssh/authorized_keys"
    echo "  2. 在 GitHub 仓库设置中添加服务器信息到 Secrets："
    echo "     - SERVER_HOST: $(curl -s ifconfig.me)"
    echo "     - SERVER_USER: deploy"
    echo "     - SERVER_SSH_KEY: <你的SSH私钥>"
    echo "  3. 推送代码到 main 分支触发自动部署"
    echo ""
    echo "🌐 测试访问："
    echo "  - 服务器IP: $(curl -s ifconfig.me)"
    echo "  - 测试地址: http://$(curl -s ifconfig.me)"
    echo ""
    echo "💡 有用的命令："
    echo "  - 查看 Nginx 状态: sudo systemctl status nginx"
    echo "  - 查看 Nginx 日志: sudo tail -f /var/log/nginx/error.log"
    echo "  - 重启 Nginx: sudo systemctl restart nginx"
    echo "  - 查看部署目录: ls -la /var/www/admin-system/"
    echo ""
}

# 主函数
main() {
    log_info "开始服务器初始化..."
    
    check_root
    update_system
    install_dependencies
    install_nodejs
    install_pnpm
    create_deploy_user
    setup_sudo
    create_project_dirs
    setup_nginx
    setup_firewall
    create_deployment_example
    install_monitoring
    show_summary
    
    log_info "✅ 所有配置完成！"
}

# 错误处理
trap 'log_error "脚本执行失败！请检查错误信息。"' ERR

# 执行主函数
main