#!/bin/bash

# SCP部署测试脚本
# 用法: ./scripts/test-scp-deployment.sh [config_file]
# 例如: ./scripts/test-scp-deployment.sh deployment.env

set -e

CONFIG_FILE=${1:-deployment.env}

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

echo "🚀 SCP部署测试工具"
echo "====================="

# 加载配置文件
if [[ -f "$CONFIG_FILE" ]]; then
    log_info "加载配置文件: $CONFIG_FILE"
    source "$CONFIG_FILE"
else
    log_warn "配置文件 $CONFIG_FILE 不存在，使用环境变量"
fi

# 检查必要的环境变量
required_vars=("SERVER_HOST" "SERVER_USER" "DEPLOY_PATH")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        log_error "缺少必要的环境变量: $var"
        echo "请设置以下环境变量或在配置文件中定义："
        echo "- SERVER_HOST: 服务器主机名或IP"
        echo "- SERVER_USER: SSH用户名"
        echo "- DEPLOY_PATH: 部署路径"
        echo "- SERVER_PORT: SSH端口（可选，默认22）"
        echo "- SSH_KEY: SSH私钥内容（可选）"
        echo "- KNOWN_HOSTS: 服务器主机密钥（可选）"
        exit 1
    fi
done

SERVER_PORT=${SERVER_PORT:-22}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log_info "测试配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo "  端口: $SERVER_PORT"
echo "  部署路径: $DEPLOY_PATH"
echo "  时间戳: $TIMESTAMP"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
chmod 700 "$TEMP_DIR"
REMOTE_TEMP_DIR="/tmp/scp-deploy-test-${TIMESTAMP}"

log_info "创建临时目录: $TEMP_DIR"

# 清理函数
cleanup() {
    echo ""
    log_info "清理临时文件..."
    rm -rf "$TEMP_DIR"
    ssh "${SERVER_HOST}" "rm -rf ${REMOTE_TEMP_DIR}" 2>/dev/null || true
}

# 设置清理陷阱
trap cleanup EXIT

# 配置SSH（复用SSH配置函数）
setup_ssh() {
    log_step "配置SSH环境..."
    
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    SSH_KEY_FILE="$HOME/.ssh/deploy_key"
    
    if [[ -n "$SSH_KEY" ]]; then
        echo "$SSH_KEY" > "$SSH_KEY_FILE"
        chmod 600 "$SSH_KEY_FILE"
        log_info "SSH私钥已写入: $SSH_KEY_FILE"
    elif [[ -f "$SSH_KEY_FILE" ]]; then
        log_info "使用现有SSH私钥: $SSH_KEY_FILE"
    else
        log_warn "未找到SSH私钥，尝试使用默认密钥"
    fi
    
    # 配置SSH选项
    cat > ~/.ssh/config << EOF
Host ${SERVER_HOST}
    HostName ${SERVER_HOST}
    User ${SERVER_USER}
    Port ${SERVER_PORT}
EOF

    if [[ -f "$SSH_KEY_FILE" ]]; then
        echo "    IdentityFile ${SSH_KEY_FILE}" >> ~/.ssh/config
        echo "    IdentitiesOnly yes" >> ~/.ssh/config
    fi
    
    if [[ -n "$KNOWN_HOSTS" ]]; then
        echo "$KNOWN_HOSTS" >> ~/.ssh/known_hosts
        chmod 600 ~/.ssh/known_hosts
        echo "    StrictHostKeyChecking yes" >> ~/.ssh/config
        log_info "已添加服务器主机密钥到 known_hosts"
    else
        cat >> ~/.ssh/config << EOF
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel ERROR
EOF
        log_warn "禁用严格主机密钥检查"
    fi
    
    chmod 600 ~/.ssh/config
}

# 测试1: SSH连接测试
test_ssh_connection() {
    log_step "测试1: SSH连接测试"
    
    if ssh -o ConnectTimeout=10 "${SERVER_HOST}" "echo 'SSH连接成功'" 2>/dev/null; then
        log_info "✅ SSH连接测试通过"
        return 0
    else
        log_error "❌ SSH连接测试失败"
        return 1
    fi
}

# 测试2: 创建测试文件
create_test_files() {
    log_step "测试2: 创建测试文件"
    
    cd "$TEMP_DIR"
    
    # 创建模拟的构建产物
    mkdir -p dist/assets
    
    cat > dist/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>SCP部署测试</title>
</head>
<body>
    <h1>SCP部署测试页面</h1>
    <p>部署时间: <span id="timestamp"></span></p>
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
EOF

    cat > dist/assets/app.js << 'EOF'
console.log('SCP部署测试应用启动');
console.log('时间戳:', new Date().toISOString());
EOF

    cat > dist/assets/style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 40px;
    background-color: #f5f5f5;
}
h1 {
    color: #333;
}
EOF

    # 创建部署脚本
    cat > deploy_script.sh << 'DEPLOY_SCRIPT'
#!/bin/bash
set -e

TIMESTAMP="$1"
DEPLOY_PATH="$2"

echo "开始SCP部署测试..."
echo "时间戳: $TIMESTAMP"
echo "部署路径: $DEPLOY_PATH"

# 创建版本目录
mkdir -p "${DEPLOY_PATH}/releases/${TIMESTAMP}"

# 移动文件到版本目录
echo "移动文件到版本目录..."
mv ./dist/* "${DEPLOY_PATH}/releases/${TIMESTAMP}/" 2>/dev/null || true

# 创建软链接到当前版本
echo "创建软链接..."
ln -sfn "${DEPLOY_PATH}/releases/${TIMESTAMP}" "${DEPLOY_PATH}/current"

# 显示结果
echo "部署完成，文件列表:"
ls -la "${DEPLOY_PATH}/current/"

echo "✅ SCP部署测试完成"
DEPLOY_SCRIPT

    chmod +x deploy_script.sh
    
    log_info "✅ 测试文件创建完成"
    log_debug "文件列表:"
    find . -type f | sed 's/^/  /'
}

# 测试3: 创建远程目录
test_remote_directory() {
    log_step "测试3: 创建远程临时目录"
    
    if ssh "${SERVER_HOST}" "mkdir -p ${REMOTE_TEMP_DIR} && echo '远程目录创建成功'"; then
        log_info "✅ 远程目录创建成功"
        return 0
    else
        log_error "❌ 远程目录创建失败"
        return 1
    fi
}

# 测试4: SCP文件传输
test_scp_transfer() {
    log_step "测试4: SCP文件传输测试"
    
    # 上传构建产物
    log_info "上传构建产物..."
    if scp -r dist "${SERVER_HOST}:${REMOTE_TEMP_DIR}/"; then
        log_info "✅ 构建产物上传成功"
    else
        log_error "❌ 构建产物上传失败"
        return 1
    fi
    
    # 上传部署脚本
    log_info "上传部署脚本..."
    if scp deploy_script.sh "${SERVER_HOST}:${REMOTE_TEMP_DIR}/"; then
        log_info "✅ 部署脚本上传成功"
    else
        log_error "❌ 部署脚本上传失败"
        return 1
    fi
    
    # 验证文件传输
    log_info "验证远程文件..."
    if ssh "${SERVER_HOST}" "ls -la ${REMOTE_TEMP_DIR}/"; then
        log_info "✅ 文件传输验证成功"
        return 0
    else
        log_error "❌ 文件传输验证失败"
        return 1
    fi
}

# 测试5: 远程部署执行
test_remote_deployment() {
    log_step "测试5: 远程部署执行测试"
    
    # 确保部署目录存在
    ssh "${SERVER_HOST}" "mkdir -p ${DEPLOY_PATH}"
    
    # 执行部署脚本
    log_info "执行远程部署脚本..."
    if ssh "${SERVER_HOST}" "cd ${REMOTE_TEMP_DIR} && bash deploy_script.sh ${TIMESTAMP} ${DEPLOY_PATH}"; then
        log_info "✅ 远程部署执行成功"
    else
        log_error "❌ 远程部署执行失败"
        return 1
    fi
    
    # 验证部署结果
    log_info "验证部署结果..."
    if ssh "${SERVER_HOST}" "test -L ${DEPLOY_PATH}/current && ls -la ${DEPLOY_PATH}/current/"; then
        log_info "✅ 部署结果验证成功"
        
        # 显示部署的文件
        echo ""
        log_debug "部署的文件内容:"
        ssh "${SERVER_HOST}" "cat ${DEPLOY_PATH}/current/index.html | head -5"
        
        return 0
    else
        log_error "❌ 部署结果验证失败"
        return 1
    fi
}

# 测试6: 清理测试
test_cleanup() {
    log_step "测试6: 清理测试"
    
    # 清理远程临时文件
    log_info "清理远程临时文件..."
    if ssh "${SERVER_HOST}" "rm -rf ${REMOTE_TEMP_DIR}"; then
        log_info "✅ 远程临时文件清理成功"
    else
        log_warn "⚠️ 远程临时文件清理失败"
    fi
    
    # 清理测试部署（可选）
    read -p "是否清理测试部署的文件？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "清理测试部署..."
        ssh "${SERVER_HOST}" "rm -rf ${DEPLOY_PATH}/releases/${TIMESTAMP}" || true
        log_info "✅ 测试部署清理完成"
    else
        log_info "保留测试部署，路径: ${DEPLOY_PATH}/releases/${TIMESTAMP}"
    fi
}

# 运行所有测试
run_all_tests() {
    local failed=0
    
    setup_ssh || ((failed++))
    test_ssh_connection || ((failed++))
    create_test_files || ((failed++))
    test_remote_directory || ((failed++))
    test_scp_transfer || ((failed++))
    test_remote_deployment || ((failed++))
    test_cleanup || ((failed++))
    
    echo ""
    if [[ $failed -eq 0 ]]; then
        log_info "🎉 所有SCP部署测试通过！"
        echo ""
        echo "💡 说明："
        echo "- SCP部署方式工作正常"
        echo "- 可以开始使用 ./scripts/deploy.sh 进行实际部署"
        echo "- 详细部署指南请参考 docs/scp-deployment.md"
    else
        log_error "❌ $failed 个测试失败"
        echo ""
        echo "🔧 故障排除建议："
        echo "1. 检查SSH连接和认证配置"
        echo "2. 确保服务器目录权限正确"
        echo "3. 查看详细错误信息进行调试"
        echo "4. 参考 docs/ssh-setup.md 解决SSH问题"
        exit 1
    fi
}

# 主函数
main() {
    run_all_tests
}

# 运行主函数
main