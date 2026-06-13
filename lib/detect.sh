# shellcheck shell=bash

# ============================================================
# 系统检测
# ============================================================
detect_os() {
    if [ -f /etc/os-release ]; then
        _SAVED_VERSION=$VERSION
        . /etc/os-release
        OS_NAME=$ID
        OS_VER=$VERSION_ID
        OS_PRETTY=$PRETTY_NAME
        VERSION=$_SAVED_VERSION
    else
        error "无法检测系统版本"
        exit 1
    fi

    case $OS_NAME in
        debian|ubuntu)
            PKG_MANAGER="apt"
            PKG_UPDATE="apt update -y"
            PKG_INSTALL="apt install -y"
            FIREWALL="ufw"
            ;;
        centos|rhel|almalinux|rocky)
            if command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
                PKG_UPDATE="dnf update -y"
                PKG_INSTALL="dnf install -y"
            else
                PKG_MANAGER="yum"
                PKG_UPDATE="yum update -y"
                PKG_INSTALL="yum install -y"
            fi
            FIREWALL="firewalld"
            ;;
        fedora)
            PKG_MANAGER="dnf"
            PKG_UPDATE="dnf update -y"
            PKG_INSTALL="dnf install -y"
            FIREWALL="firewalld"
            ;;
        alpine)
            PKG_MANAGER="apk"
            PKG_UPDATE="apk update"
            PKG_INSTALL="apk add"
            FIREWALL="iptables"
            ;;
        *)
            warning "未经测试的系统：$OS_PRETTY，将尝试继续..."
            PKG_MANAGER="apt"
            PKG_UPDATE="apt update -y"
            PKG_INSTALL="apt install -y"
            FIREWALL="ufw"
            ;;
    esac

    success "检测到系统：$OS_PRETTY"
}

# 检测已安装组件
check_installed() {
    DOCKER_INSTALLED=false
    NGINX_INSTALLED=false
    CERTBOT_INSTALLED=false
    ACME_INSTALLED=false
    UFW_INSTALLED=false
    FAIL2BAN_INSTALLED=false

    command -v docker >/dev/null 2>&1 && DOCKER_INSTALLED=true
    command -v nginx >/dev/null 2>&1 && NGINX_INSTALLED=true
    command -v certbot >/dev/null 2>&1 && CERTBOT_INSTALLED=true
    [ -f ~/.acme.sh/acme.sh ] && ACME_INSTALLED=true
    command -v ufw >/dev/null 2>&1 && UFW_INSTALLED=true
    command -v fail2ban-server >/dev/null 2>&1 && FAIL2BAN_INSTALLED=true
}

# 检查 root 权限
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "请使用 root 权限运行此脚本"
        exit 1
    fi
}
