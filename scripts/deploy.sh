#!/bin/bash

# 部署脚本
# 用法: ./scripts/deploy.sh [environment] [service]
# 例如: ./scripts/deploy.sh production admin-system

set -e

ENVIRONMENT=${1:-production}
SERVICE=${2:-all}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚀 开始部署 - 环境: $ENVIRONMENT, 服务: $SERVICE"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查环境变量
check_env() {
    if [[ "$ENVIRONMENT" == "production" ]]; then
        required_vars=("SERVER_HOST" "SERVER_USER" "DEPLOY_PATH")
        for var in "${required_vars[@]}"; do
            if [[ -z "${!var}" ]]; then
                log_error "缺少必要的环境变量: $var"
                exit 1
            fi
        done
    fi
}

# 配置SSH
setup_ssh() {
    if [[ "$ENVIRONMENT" != "production" ]]; then
        return
    fi
    
    log_info "配置SSH连接..."
    
    # 创建SSH目录
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # SSH密钥文件路径
    SSH_KEY_FILE="$HOME/.ssh/deploy_key"
    
    # 如果设置了SSH_KEY环境变量，写入私钥文件
    if [[ -n "$SSH_KEY" ]]; then
        echo "$SSH_KEY" > "$SSH_KEY_FILE"
        chmod 600 "$SSH_KEY_FILE"
        log_info "SSH私钥已写入: $SSH_KEY_FILE"
    elif [[ -f "$SSH_KEY_FILE" ]]; then
        log_info "使用现有SSH私钥: $SSH_KEY_FILE"
    else
        log_error "未找到SSH私钥，请设置SSH_KEY环境变量或确保~/.ssh/deploy_key存在"
        exit 1
    fi
    
    # 配置SSH选项
    cat > ~/.ssh/config << EOF
Host ${SERVER_HOST}
    HostName ${SERVER_HOST}
    User ${SERVER_USER}
    Port ${SERVER_PORT:-22}
    IdentityFile ${SSH_KEY_FILE}
    IdentitiesOnly yes
EOF
    
    # 配置known_hosts
    if [[ -n "$KNOWN_HOSTS" ]]; then
        echo "$KNOWN_HOSTS" >> ~/.ssh/known_hosts
        chmod 600 ~/.ssh/known_hosts
        log_info "已添加服务器主机密钥到 known_hosts"
        echo "    StrictHostKeyChecking yes" >> ~/.ssh/config
    else
        log_warn "未设置 KNOWN_HOSTS，将禁用严格主机密钥检查"
        cat >> ~/.ssh/config << EOF
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel ERROR
EOF
    fi
    
    chmod 600 ~/.ssh/config
    log_info "SSH配置已完成"
}

# 构建项目
build_project() {
    log_info "安装依赖..."
    pnpm install --frozen-lockfile

    if [[ "$SERVICE" == "all" || "$SERVICE" == "ui-components" ]]; then
        log_info "构建 UI Components..."
        pnpm --filter @monorepo-project/ui-components build
    fi

    if [[ "$SERVICE" == "all" || "$SERVICE" == "admin-system" ]]; then
        log_info "构建 Admin System..."
        pnpm --filter @monorepo-project/admin-system build
    fi
}

# 创建部署包
create_deployment_package() {
    log_info "创建部署包..."
    mkdir -p deployment-packages

    if [[ "$SERVICE" == "all" || "$SERVICE" == "ui-components" ]]; then
        cd packages/ui-components
        tar -czf "../../deployment-packages/ui-components-${TIMESTAMP}.tar.gz" dist package.json
        cd ../..
        log_info "UI Components 部署包已创建: ui-components-${TIMESTAMP}.tar.gz"
    fi

    if [[ "$SERVICE" == "all" || "$SERVICE" == "admin-system" ]]; then
        cd apps/admin-system
        tar -czf "../../deployment-packages/admin-system-${TIMESTAMP}.tar.gz" dist
        cd ../..
        log_info "Admin System 部署包已创建: admin-system-${TIMESTAMP}.tar.gz"
    fi
}

# 使用SCP方式部署到服务器
deploy_to_server() {
    if [[ "$ENVIRONMENT" != "production" ]]; then
        log_warn "非生产环境，跳过部署到服务器"
        return
    fi

    log_info "使用SCP方式部署到服务器..."

    if [[ "$SERVICE" == "all" || "$SERVICE" == "admin-system" ]]; then
        # 测试SSH/SCP连接
        log_info "测试SSH连接到 ${SERVER_HOST}..."
        if ! ssh -o ConnectTimeout=10 "${SERVER_HOST}" "echo 'SSH连接测试成功'"; then
            log_error "SSH连接失败，请检查网络连接和认证配置"
            exit 1
        fi

        # 准备本地临时目录进行文件处理
        local temp_dir="deployment-temp-${TIMESTAMP}"
        mkdir -p "$temp_dir"
        
        log_info "准备部署文件..."
        cd "$temp_dir"
        
        # 解压部署包到临时目录
        tar -xzf "../deployment-packages/admin-system-${TIMESTAMP}.tar.gz"
        
        # 创建部署脚本
        cat > deploy_script.sh << 'DEPLOY_SCRIPT'
#!/bin/bash
set -e

TIMESTAMP="$1"
DEPLOY_PATH="$2"

echo "开始SCP部署流程..."
echo "时间戳: $TIMESTAMP"
echo "部署路径: $DEPLOY_PATH"

# 创建版本目录
mkdir -p "${DEPLOY_PATH}/releases/${TIMESTAMP}"

# 移动文件到版本目录
mv ./dist/* "${DEPLOY_PATH}/releases/${TIMESTAMP}/" 2>/dev/null || true

# 创建软链接到当前版本
ln -sfn "${DEPLOY_PATH}/releases/${TIMESTAMP}" "${DEPLOY_PATH}/current"

# 重启Web服务器
sudo systemctl reload nginx || true

# 清理旧版本（保留最近5个）
cd "${DEPLOY_PATH}/releases"
ls -t | tail -n +6 | xargs rm -rf 2>/dev/null || true

echo "✅ SCP部署完成"
DEPLOY_SCRIPT

        chmod +x deploy_script.sh
        
        # 使用SCP上传所有文件
        log_info "上传文件到服务器..."
        
        # 创建远程临时目录
        remote_temp_dir="/tmp/deploy-${TIMESTAMP}"
        ssh "${SERVER_HOST}" "mkdir -p ${remote_temp_dir}"
        
        # 上传构建产物
        log_info "上传构建产物..."
        scp -r dist "${SERVER_HOST}:${remote_temp_dir}/"
        
        # 上传部署脚本
        log_info "上传部署脚本..."
        scp deploy_script.sh "${SERVER_HOST}:${remote_temp_dir}/"
        
        # 执行部署
        log_info "执行远程部署..."
        ssh "${SERVER_HOST}" "cd ${remote_temp_dir} && bash deploy_script.sh ${TIMESTAMP} ${DEPLOY_PATH}"
        
        # 清理远程临时文件
        log_info "清理临时文件..."
        ssh "${SERVER_HOST}" "rm -rf ${remote_temp_dir}"
        
        # 清理本地临时目录
        cd ..
        rm -rf "$temp_dir"
        
        log_info "✅ Admin System SCP部署完成"
    fi
}

# 健康检查
health_check() {
    if [[ "$ENVIRONMENT" != "production" ]]; then
        log_warn "非生产环境，跳过健康检查"
        return
    fi

    log_info "执行健康检查..."
    sleep 10

    # 检查应用状态
    if [[ -n "$APP_URL" ]]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL" || echo "000")
        if [[ "$response" == "200" ]]; then
            log_info "✅ 健康检查通过"
        else
            log_error "❌ 健康检查失败，状态码: $response"
            exit 1
        fi
    else
        log_warn "APP_URL 未设置，跳过健康检查"
    fi
}

# 回滚函数
rollback() {
    log_warn "执行回滚..."
    ssh "${SERVER_HOST}" << EOF
        cd ${DEPLOY_PATH}/releases
        previous=\$(ls -t | head -n 2 | tail -n 1)
        if [[ -n "\$previous" ]]; then
            ln -sfn ${DEPLOY_PATH}/releases/\$previous ${DEPLOY_PATH}/current
            sudo systemctl reload nginx || true
            echo "✅ 回滚到版本: \$previous"
        else
            echo "❌ 没有可用的回滚版本"
            exit 1
        fi
EOF
}

# 主流程
main() {
    log_info "开始部署流程..."
    
    check_env
    setup_ssh
    build_project
    create_deployment_package
    deploy_to_server
    health_check
    
    log_info "🎉 部署完成！"
}

# 捕获错误并提供回滚选项
trap 'log_error "部署失败！"; read -p "是否需要回滚？(y/N): " -n 1 -r; echo; if [[ $REPLY =~ ^[Yy]$ ]]; then rollback; fi' ERR

# 如果是回滚命令
if [[ "$1" == "rollback" ]]; then
    rollback
    exit 0
fi

# 执行主流程
main