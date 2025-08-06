#!/bin/bash

# 获取服务器SSH指纹脚本
# 用法: ./scripts/get-server-fingerprint.sh <server_host> [port]
# 例如: ./scripts/get-server-fingerprint.sh example.com 22

set -e

HOST=${1}
PORT=${2:-22}

if [[ -z "$HOST" ]]; then
    echo "❌ 错误: 请提供服务器主机名或IP地址"
    echo "用法: $0 <server_host> [port]"
    echo "例如: $0 example.com 22"
    exit 1
fi

echo "🔍 获取服务器 $HOST:$PORT 的SSH指纹..."

# 获取服务器的SSH主机密钥
echo "📋 SSH主机密钥 (添加到 known_hosts):"
echo "----------------------------------------"
ssh-keyscan -H -p "$PORT" "$HOST" 2>/dev/null

echo ""
echo "🔑 SSH指纹信息:"
echo "----------------------------------------"

# 获取不同类型的指纹
for key_type in rsa ed25519 ecdsa; do
    fingerprint=$(ssh-keyscan -t "$key_type" -p "$PORT" "$HOST" 2>/dev/null | ssh-keygen -lf - 2>/dev/null | head -n1)
    if [[ -n "$fingerprint" ]]; then
        echo "$key_type: $fingerprint"
    fi
done

echo ""
echo "📝 使用说明:"
echo "1. 将上面的SSH主机密钥添加到GitHub Secrets中的 KNOWN_HOSTS"
echo "2. 或者在部署脚本中使用 StrictHostKeyChecking=no (不推荐用于生产环境)"
echo "3. 推荐在服务器初始化时手动验证指纹的正确性"