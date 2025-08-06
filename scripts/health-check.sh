#!/bin/bash

# 健康检查脚本
# 用法: ./scripts/health-check.sh [url]

set -e

URL=${1:-"http://localhost:3000"}
MAX_RETRIES=30
RETRY_INTERVAL=2

echo "🏥 开始健康检查: $URL"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

check_http_status() {
    local url=$1
    local expected_status=${2:-200}
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [[ "$response" == "$expected_status" ]]; then
        return 0
    else
        return 1
    fi
}

check_service_health() {
    local url=$1
    local retries=0
    
    while [[ $retries -lt $MAX_RETRIES ]]; do
        if check_http_status "$url"; then
            log_info "✅ 服务健康检查通过 ($url)"
            return 0
        else
            retries=$((retries + 1))
            log_warn "⏳ 健康检查失败，重试 $retries/$MAX_RETRIES..."
            sleep $RETRY_INTERVAL
        fi
    done
    
    log_error "❌ 服务健康检查失败，已超过最大重试次数"
    return 1
}

# 检查多个端点
check_multiple_endpoints() {
    local base_url=$1
    local endpoints=("/" "/health" "/api/health")
    
    for endpoint in "${endpoints[@]}"; do
        local full_url="${base_url}${endpoint}"
        log_info "检查端点: $full_url"
        
        if check_http_status "$full_url"; then
            log_info "✅ 端点检查通过: $endpoint"
        else
            log_warn "⚠️  端点检查失败: $endpoint"
        fi
    done
}

# 主检查流程
main() {
    log_info "开始健康检查..."
    
    # 基本连通性检查
    if check_service_health "$URL"; then
        log_info "✅ 基本健康检查通过"
        
        # 检查多个端点
        check_multiple_endpoints "$URL"
        
        log_info "🎉 健康检查完成"
        exit 0
    else
        log_error "❌ 健康检查失败"
        exit 1
    fi
}

main