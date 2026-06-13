# shellcheck shell=bash

# ============================================================
#        noob ra2 VPS 工具箱
#        by noob ra2
#        版本：0.2.0
# ============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# 版本
VERSION="0.2.0"
SCRIPT_VERSION="0.2.0"
GITHUB_RAW="https://raw.githubusercontent.com/leungbzai-png/vps-toolkit/refs/heads/main/setup.sh"

# ============================================================
# 工具函数
# ============================================================

# 打印标题
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════╗"
    echo "║         $BANNER_TITLE              ║"
    echo "║              v${SCRIPT_VERSION}                       ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 打印分隔线
print_line() {
    echo -e "${BLUE}──────────────────────────────────────────${NC}"
}

# 成功提示
success() { echo -e "${GREEN}✅ $1${NC}"; }

# 错误提示
error() { echo -e "${RED}❌ $1${NC}"; }

# 警告提示
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# 信息提示
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# 安全提示
security_tip() { echo -e "${PURPLE}🔒 安全提示：$1${NC}"; }

# 确认操作
confirm() {
    read -p "$(echo -e ${YELLOW}"$1 $MSG_CONFIRM_YN："${NC})" CONFIRM
    [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]
}

# 生成随机密码
gen_pass() {
    tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c 32
}

# 获取公网 IP
get_public_ip() {
    curl -s4 ifconfig.me 2>/dev/null || curl -s4 ip.sb 2>/dev/null || echo "无法获取"
}

# 保存部署信息
save_info() {
    echo "$1" >> /root/deploy_info.txt
}
