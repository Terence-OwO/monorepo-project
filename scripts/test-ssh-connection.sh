#!/bin/bash

# SSH连接测试脚本
# 用法: ./scripts/test-ssh-connection.sh [config_file]
# 例如: ./scripts/test-ssh-connection.sh deployment.env

set -e

CONFIG_FILE=${1:-deployment.env}

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

echo "🔧 SSH连接测试工具"
echo "===================="

# 加载配置文件
if [[ -f "$CONFIG_FILE" ]]; then
    log_info "加载配置文件: $CONFIG_FILE"
    source "$CONFIG_FILE"
else
    log_warn "配置文件 $CONFIG_FILE 不存在，使用环境变量"
fi

# 检查必要的环境变量
required_vars=("SERVER_HOST" "SERVER_USER")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        log_error "缺少必要的环境变量: $var"
        echo "请设置以下环境变量或在配置文件中定义："
        echo "- SERVER_HOST: 服务器主机名或IP"
        echo "- SERVER_USER: SSH用户名"
        echo "- SERVER_PORT: SSH端口（可选，默认22）"
        echo "- SSH_KEY: SSH私钥内容（可选）"
        echo "- KNOWN_HOSTS: 服务器主机密钥（可选）"
        exit 1
    fi
done

SERVER_PORT=${SERVER_PORT:-22}

log_info "测试配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo "  端口: $SERVER_PORT"

# 创建临时SSH目录
TEMP_SSH_DIR=$(mktemp -d)
chmod 700 "$TEMP_SSH_DIR"

log_info "创建临时SSH配置: $TEMP_SSH_DIR"

# 配置SSH密钥
SSH_KEY_FILE="$TEMP_SSH_DIR/test_key"
if [[ -n "$SSH_KEY" ]]; then
    echo "$SSH_KEY" > "$SSH_KEY_FILE"
    chmod 600 "$SSH_KEY_FILE"
    log_info "使用提供的SSH私钥"
elif [[ -f "$HOME/.ssh/deploy_key" ]]; then
    cp "$HOME/.ssh/deploy_key" "$SSH_KEY_FILE"
    chmod 600 "$SSH_KEY_FILE"
    log_info "使用现有的deploy_key"
elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
    cp "$HOME/.ssh/id_rsa" "$SSH_KEY_FILE"
    chmod 600 "$SSH_KEY_FILE"
    log_info "使用默认的id_rsa"
elif [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    cp "$HOME/.ssh/id_ed25519" "$SSH_KEY_FILE"
    chmod 600 "$SSH_KEY_FILE"
    log_info "使用默认的id_ed25519"
else
    log_warn "未找到SSH私钥，尝试使用ssh-agent或密码认证"
    SSH_KEY_FILE=""
fi

# 创建SSH配置文件
SSH_CONFIG_FILE="$TEMP_SSH_DIR/config"
cat > "$SSH_CONFIG_FILE" << EOF
Host test-server
    HostName $SERVER_HOST
    User $SERVER_USER
    Port $SERVER_PORT
EOF

if [[ -n "$SSH_KEY_FILE" ]]; then
    echo "    IdentityFile $SSH_KEY_FILE" >> "$SSH_CONFIG_FILE"
    echo "    IdentitiesOnly yes" >> "$SSH_CONFIG_FILE"
fi

# 配置known_hosts
KNOWN_HOSTS_FILE="$TEMP_SSH_DIR/known_hosts"
if [[ -n "$KNOWN_HOSTS" ]]; then
    echo "$KNOWN_HOSTS" > "$KNOWN_HOSTS_FILE"
    chmod 600 "$KNOWN_HOSTS_FILE"
    echo "    StrictHostKeyChecking yes" >> "$SSH_CONFIG_FILE"
    echo "    UserKnownHostsFile $KNOWN_HOSTS_FILE" >> "$SSH_CONFIG_FILE"
    log_info "使用提供的known_hosts"
else
    echo "    StrictHostKeyChecking no" >> "$SSH_CONFIG_FILE"
    echo "    UserKnownHostsFile /dev/null" >> "$SSH_CONFIG_FILE"
    echo "    LogLevel ERROR" >> "$SSH_CONFIG_FILE"
    log_warn "禁用严格主机密钥检查（不推荐生产环境）"
fi

log_debug "SSH配置文件内容:"
cat "$SSH_CONFIG_FILE" | sed 's/^/  /'

echo ""
log_info "开始SSH连接测试..."

# 测试1: 基本连接测试
echo ""
echo "📡 测试1: 基本连接测试"
if ssh -F "$SSH_CONFIG_FILE" -o ConnectTimeout=10 test-server "echo 'SSH连接成功'" 2>/dev/null; then
    log_info "✅ 基本连接测试通过"
else
    log_error "❌ 基本连接测试失败"
    echo ""
    log_debug "尝试详细输出模式..."
    ssh -F "$SSH_CONFIG_FILE" -v test-server "echo 'SSH连接测试'" 2>&1 | head -20
    cleanup_and_exit 1
fi

# 测试2: 权限测试
echo ""
echo "🔐 测试2: 权限测试"
if ssh -F "$SSH_CONFIG_FILE" test-server "whoami && pwd && ls -la" >/dev/null 2>&1; then
    log_info "✅ 权限测试通过"
    
    # 显示用户信息
    user_info=$(ssh -F "$SSH_CONFIG_FILE" test-server "whoami && pwd")
    echo "  当前用户: $(echo "$user_info" | head -1)"
    echo "  工作目录: $(echo "$user_info" | tail -1)"
else
    log_error "❌ 权限测试失败"
    cleanup_and_exit 1
fi

# 测试3: 文件传输测试
echo ""
echo "📁 测试3: 文件传输测试"
test_file="$TEMP_SSH_DIR/test_upload.txt"
echo "SSH连接测试文件 - $(date)" > "$test_file"

if scp -F "$SSH_CONFIG_FILE" "$test_file" test-server:/tmp/ssh_test_$(date +%s).txt >/dev/null 2>&1; then
    log_info "✅ 文件传输测试通过"
else
    log_error "❌ 文件传输测试失败"
    cleanup_and_exit 1
fi

# 测试4: 部署目录权限测试
if [[ -n "$DEPLOY_PATH" ]]; then
    echo ""
    echo "📂 测试4: 部署目录权限测试"
    if ssh -F "$SSH_CONFIG_FILE" test-server "mkdir -p $DEPLOY_PATH/test && echo 'success' > $DEPLOY_PATH/test/test.txt && rm -rf $DEPLOY_PATH/test" >/dev/null 2>&1; then
        log_info "✅ 部署目录权限测试通过"
        echo "  部署路径: $DEPLOY_PATH"
    else
        log_error "❌ 部署目录权限测试失败"
        echo "  部署路径: $DEPLOY_PATH"
        echo "  请检查目录权限或使用sudo权限"
    fi
fi

# 清理函数
cleanup_and_exit() {
    echo ""
    log_info "清理临时文件..."
    rm -rf "$TEMP_SSH_DIR"
    exit ${1:-0}
}

echo ""
log_info "🎉 所有测试完成！SSH连接配置正常。"

echo ""
echo "💡 建议:"
echo "1. 确保在GitHub Secrets中配置了正确的SSH密钥"
echo "2. 如果可能，配置KNOWN_HOSTS以提高安全性"
echo "3. 定期检查SSH密钥的有效性"

cleanup_and_exit 0