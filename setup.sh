#!/bin/bash
# ============================================================
#        noob ra2 VPS 工具箱
#        by noob ra2
#        版本：1.0.0
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
VERSION="1.0.0"
GITHUB_RAW="https://raw.githubusercontent.com/noobra2/vps-toolkit/main/setup.sh"

# ============================================================
# 工具函数
# ============================================================

# 打印标题
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════╗"
    echo "║         noob ra2 VPS 工具箱              ║"
    echo "║              v${VERSION}                       ║"
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
    read -p "$(echo -e ${YELLOW}"$1 (y/n)："${NC})" CONFIRM
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

# ============================================================
# 系统检测
# ============================================================
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$ID
        OS_VERSION=$VERSION_ID
        OS_PRETTY=$PRETTY_NAME
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

# ============================================================
# 安装基础依赖
# ============================================================
install_base() {
    info "更新系统软件包..."
    $PKG_UPDATE >/dev/null 2>&1

    # 安装基础工具
    case $PKG_MANAGER in
        apt)
            $PKG_INSTALL curl wget sudo openssl rsyslog >/dev/null 2>&1
            ;;
        yum|dnf)
            $PKG_INSTALL curl wget sudo openssl rsyslog >/dev/null 2>&1
            ;;
        apk)
            $PKG_INSTALL curl wget openssl >/dev/null 2>&1
            ;;
    esac
    success "基础工具已安装"

    # Docker
    if [ "$DOCKER_INSTALLED" = false ]; then
        info "安装 Docker..."
        curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
        systemctl enable --now docker >/dev/null 2>&1
        apt install -y docker-compose-plugin >/dev/null 2>&1
        DOCKER_INSTALLED=true
        success "Docker 已安装"
    else
        success "Docker 已安装，跳过"
    fi

    # Nginx
    if [ "$NGINX_INSTALLED" = false ]; then
        info "安装 Nginx..."
        $PKG_INSTALL nginx >/dev/null 2>&1
        systemctl enable --now nginx >/dev/null 2>&1
        NGINX_INSTALLED=true
        success "Nginx 已安装"
    else
        success "Nginx 已安装，跳过"
    fi

    # Certbot
    if [ "$CERTBOT_INSTALLED" = false ]; then
        info "安装 Certbot..."
        case $PKG_MANAGER in
            apt)
                $PKG_INSTALL certbot python3-certbot-nginx >/dev/null 2>&1
                ;;
            yum|dnf)
                $PKG_INSTALL certbot python3-certbot-nginx >/dev/null 2>&1
                ;;
        esac
        CERTBOT_INSTALLED=true
        success "Certbot 已安装"
    else
        success "Certbot 已安装，跳过"
    fi
}

# ============================================================
# 防火墙管理（兼容 UFW 和 firewalld）
# ============================================================
fw_allow_port() {
    local PORT=$1
    local PROTO=${2:-tcp}
    case $FIREWALL in
        ufw)
            ufw allow $PORT/$PROTO >/dev/null 2>&1
            ;;
        firewalld)
            firewall-cmd --permanent --add-port=$PORT/$PROTO >/dev/null 2>&1
            firewall-cmd --reload >/dev/null 2>&1
            ;;
        iptables)
            iptables -I INPUT -p $PROTO --dport $PORT -j ACCEPT
            ;;
    esac
}

fw_delete_port() {
    local PORT=$1
    local PROTO=${2:-tcp}
    case $FIREWALL in
        ufw)
            ufw delete allow $PORT/$PROTO >/dev/null 2>&1
            ;;
        firewalld)
            firewall-cmd --permanent --remove-port=$PORT/$PROTO >/dev/null 2>&1
            firewall-cmd --reload >/dev/null 2>&1
            ;;
        iptables)
            iptables -D INPUT -p $PROTO --dport $PORT -j ACCEPT
            ;;
    esac
}

fw_enable() {
    case $FIREWALL in
        ufw)
            ufw --force enable >/dev/null 2>&1
            ;;
        firewalld)
            systemctl enable --now firewalld >/dev/null 2>&1
            ;;
    esac
}

fw_status() {
    case $FIREWALL in
        ufw)
            ufw status verbose
            ;;
        firewalld)
            firewall-cmd --list-all
            ;;
        iptables)
            iptables -L INPUT --line-numbers
            ;;
    esac
}

# ============================================================
# Nginx 配置函数
# ============================================================
setup_nginx_proxy() {
    local DOMAIN=$1
    local PORT=$2
    local CONF_DIR

    case $PKG_MANAGER in
        apt)
            CONF_DIR="/etc/nginx/sites-available"
            mkdir -p /etc/nginx/sites-enabled
            ;;
        yum|dnf|apk)
            CONF_DIR="/etc/nginx/conf.d"
            ;;
    esac

    cat > $CONF_DIR/$DOMAIN << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
    }
}
EOF

    # Debian/Ubuntu 需要创建软链接
    if [ "$PKG_MANAGER" = "apt" ]; then
        rm -f /etc/nginx/sites-enabled/$DOMAIN
        ln -s $CONF_DIR/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
    fi

    nginx -t >/dev/null 2>&1 && systemctl reload nginx >/dev/null 2>&1
    success "Nginx 反代配置完成"
}

# 申请证书
setup_cert() {
    local DOMAIN=$1
    certbot --nginx -d $DOMAIN -d www.$DOMAIN \
        --non-interactive --agree-tos \
        -m admin@$DOMAIN 2>/dev/null
    if [ $? -eq 0 ]; then
        success "SSL 证书申请成功"
    else
        warning "SSL 证书申请失败，请检查域名解析是否生效"
    fi
}

# 询问域名
ask_domain() {
    local SERVICE=$1
    echo ""
    read -p "$(echo -e ${YELLOW}"是否为 $SERVICE 配置域名？(y/n)："${NC})" HAS_DOMAIN
    if [ "$HAS_DOMAIN" = "y" ] || [ "$HAS_DOMAIN" = "Y" ]; then
        read -p "请输入域名（如 example.com，不含 www）：" INPUT_DOMAIN
        echo $INPUT_DOMAIN
    else
        echo ""
    fi
}

# ============================================================
# 1. VPS 初始化加固
# ============================================================
init_vps() {
    print_banner
    echo -e "${BOLD}=== VPS 初始化加固 ===${NC}\n"

    install_base

    # 时区设置
    echo -e "\n${CYAN}请选择时区：${NC}"
    echo "1. 亚洲/东京 (Asia/Tokyo)"
    echo "2. 亚洲/上海 (Asia/Shanghai)"
    echo "3. UTC"
    echo "4. 美国/纽约 (America/New_York)"
    echo "5. 欧洲/伦敦 (Europe/London)"
    echo "6. 自定义"
    read -p "请选择 [1-6，默认 1]：" TZ_CHOICE
    TZ_CHOICE=${TZ_CHOICE:-1}

    case $TZ_CHOICE in
        1) TIMEZONE="Asia/Tokyo" ;;
        2) TIMEZONE="Asia/Shanghai" ;;
        3) TIMEZONE="UTC" ;;
        4) TIMEZONE="America/New_York" ;;
        5) TIMEZONE="Europe/London" ;;
        6) read -p "请输入时区（如 Asia/Singapore）：" TIMEZONE ;;
        *) TIMEZONE="Asia/Tokyo" ;;
    esac

    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    success "时区已设置为：$TIMEZONE"

    # BBR 加速
    if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf 2>/dev/null; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1
        success "BBR 加速已开启"
    else
        success "BBR 加速已开启，跳过"
    fi

    # Swap 配置
    if [ ! -f /swapfile ]; then
        # 自动检测 RAM 并推荐 Swap
        RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
        if [ $RAM_MB -lt 1024 ]; then
            RECOMMENDED_SWAP="2G"
        elif [ $RAM_MB -lt 2048 ]; then
            RECOMMENDED_SWAP="2G"
        elif [ $RAM_MB -lt 4096 ]; then
            RECOMMENDED_SWAP="2G"
        else
            RECOMMENDED_SWAP="1G"
        fi

        info "检测到 RAM：${RAM_MB}MB，推荐 Swap：${RECOMMENDED_SWAP}"
        read -p "请输入 Swap 大小（直接回车使用推荐值 ${RECOMMENDED_SWAP}）：" SWAP_SIZE
        SWAP_SIZE=${SWAP_SIZE:-$RECOMMENDED_SWAP}

        fallocate -l $SWAP_SIZE /swapfile
        chmod 600 /swapfile
        mkswap /swapfile >/dev/null 2>&1
        swapon /swapfile
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
        success "Swap ${SWAP_SIZE} 已配置"
    else
        success "Swap 已配置，跳过"
    fi

    # DNS 优化
    echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
    success "DNS 已优化（Google + Cloudflare）"

    # IPv4 优先
    grep -q "^precedence ::ffff:0:0/96  100" /etc/gai.conf 2>/dev/null || \
        echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
    success "IPv4 优先已开启"

    # SSH 端口
    CURRENT_SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -n1)
    CURRENT_SSH_PORT=${CURRENT_SSH_PORT:-22}
    info "当前 SSH 端口：$CURRENT_SSH_PORT"
    read -p "请输入新 SSH 端口（直接回车保持 $CURRENT_SSH_PORT）：" SSH_PORT
    SSH_PORT=${SSH_PORT:-$CURRENT_SSH_PORT}

    # 防火墙配置
    case $FIREWALL in
        ufw)
            $PKG_INSTALL ufw >/dev/null 2>&1
            ufw --force reset >/dev/null 2>&1
            ufw default deny incoming >/dev/null 2>&1
            ufw default allow outgoing >/dev/null 2>&1
            fw_allow_port $SSH_PORT tcp
            fw_allow_port 80 tcp
            fw_allow_port 443 tcp
            ufw --force enable >/dev/null 2>&1
            success "UFW 防火墙已配置"
            ;;
        firewalld)
            $PKG_INSTALL firewalld >/dev/null 2>&1
            systemctl enable --now firewalld >/dev/null 2>&1
            fw_allow_port $SSH_PORT tcp
            fw_allow_port 80 tcp
            fw_allow_port 443 tcp
            success "firewalld 防火墙已配置"
            ;;
    esac

    # Fail2Ban
    if [ "$FAIL2BAN_INSTALLED" = false ]; then
        $PKG_INSTALL fail2ban >/dev/null 2>&1
    fi
    touch /var/log/auth.log 2>/dev/null
    cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400
findtime = 600
EOF
    systemctl enable --now fail2ban >/dev/null 2>&1
    systemctl restart fail2ban >/dev/null 2>&1
    success "Fail2Ban 已配置（3次错误封禁24小时）"

    # 修改 SSH 端口
    if [ "$SSH_PORT" != "$CURRENT_SSH_PORT" ]; then
        security_tip "修改 SSH 端口前请确认防火墙已放行新端口 $SSH_PORT"
        if confirm "确认修改 SSH 端口为 $SSH_PORT？"; then
            cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
            sed -i "s/^#\?Port .*/Port $SSH_PORT/g" /etc/ssh/sshd_config
            systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
            success "SSH 端口已改为 $SSH_PORT"
            warning "请开启新窗口用端口 $SSH_PORT 验证能否登录，确认后再关闭当前窗口！"
        fi
    fi

    print_line
    success "VPS 初始化加固完成！"
    echo ""
}

# ============================================================
# 2. 部署 WordPress
# ============================================================
deploy_wordpress() {
    print_banner
    echo -e "${BOLD}=== 部署 WordPress ===${NC}\n"

    install_base

    WP_DB_PASS=$(gen_pass)
    WP_ROOT_PASS=$(gen_pass)

    mkdir -p /opt/wordpress
    cat > /opt/wordpress/docker-compose.yml << EOF
services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: $WP_DB_PASS
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
  db:
    image: mariadb:10.11
    restart: always
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: $WP_DB_PASS
      MYSQL_ROOT_PASSWORD: $WP_ROOT_PASS
    volumes:
      - db_data:/var/lib/mysql
volumes:
  wordpress_data:
  db_data:
EOF

    info "启动 WordPress 容器..."
    cd /opt/wordpress && docker compose up -d >/dev/null 2>&1
    success "WordPress 容器已启动"

    DOMAIN=$(ask_domain "WordPress")
    if [ -n "$DOMAIN" ]; then
        setup_nginx_proxy $DOMAIN 8080
        setup_cert $DOMAIN
        ACCESS="https://$DOMAIN"
    else
        SERVER_IP=$(get_public_ip)
        ACCESS="http://$SERVER_IP:8080"
        fw_allow_port 8080 tcp
    fi

    print_line
    save_info "
=== WordPress ===
部署时间：$(date)
访问地址：$ACCESS
数据库用户：wpuser
数据库密码：$WP_DB_PASS
数据库 Root 密码：$WP_ROOT_PASS"

    success "WordPress 部署完成！"
    info "访问地址：$ACCESS"
    warning "账号信息已保存到 /root/deploy_info.txt"
    echo ""
}

# ============================================================
# 3. 部署 XBoard
# ============================================================
deploy_xboard() {
    print_banner
    echo -e "${BOLD}=== 部署 XBoard ===${NC}\n"

    install_base

    XB_DB_PASS=$(gen_pass)
    XB_ROOT_PASS=$(gen_pass)

    mkdir -p /opt/xboard
    cat > /opt/xboard/docker-compose.yml << EOF
services:
  xboard:
    image: ghcr.io/cedar2025/xboard:latest
    restart: always
    ports:
      - "7001:7001"
    volumes:
      - ./xboard:/xboard/storage
      - ./config:/xboard/.env
    depends_on:
      - db
      - redis
  db:
    image: mariadb:10.11
    restart: always
    environment:
      MYSQL_DATABASE: xboard
      MYSQL_USER: xboard
      MYSQL_PASSWORD: $XB_DB_PASS
      MYSQL_ROOT_PASSWORD: $XB_ROOT_PASS
    volumes:
      - ./db:/var/lib/mysql
  redis:
    image: redis:alpine
    restart: always
    volumes:
      - ./redis:/data
EOF

    info "启动 XBoard 容器..."
    cd /opt/xboard && docker compose up -d >/dev/null 2>&1
    success "XBoard 容器已启动"

    info "等待数据库初始化..."
    sleep 8

    echo ""
    warning "即将进入 XBoard 安装向导，请按以下信息填写："
    echo -e "  数据库地址：${GREEN}db${NC}"
    echo -e "  数据库端口：${GREEN}3306${NC}"
    echo -e "  数据库名：${GREEN}xboard${NC}"
    echo -e "  数据库用户：${GREEN}xboard${NC}"
    echo -e "  数据库密码：${GREEN}$XB_DB_PASS${NC}"
    echo ""
    read -p "按回车键继续安装向导..."

    docker compose -f /opt/xboard/docker-compose.yml exec xboard php artisan xboard:install

    DOMAIN=$(ask_domain "XBoard")
    if [ -n "$DOMAIN" ]; then
        setup_nginx_proxy $DOMAIN 7001
        setup_cert $DOMAIN
        ACCESS="https://$DOMAIN"
    else
        SERVER_IP=$(get_public_ip)
        ACCESS="http://$SERVER_IP:7001"
        fw_allow_port 7001 tcp
    fi

    print_line
    save_info "
=== XBoard ===
部署时间：$(date)
访问地址：$ACCESS
数据库用户：xboard
数据库密码：$XB_DB_PASS
数据库 Root 密码：$XB_ROOT_PASS"

    success "XBoard 部署完成！"
    info "访问地址：$ACCESS"
    warning "账号信息已保存到 /root/deploy_info.txt"
    echo ""
}

# ============================================================
# 4. 部署 3x-ui
# ============================================================
deploy_3xui() {
    print_banner
    echo -e "${BOLD}=== 部署 3x-ui ===${NC}\n"

    info "调用 3x-ui 官方安装脚本..."
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

    print_line
    success "3x-ui 部署完成！"
    warning "请记录面板账号密码并保存到 /root/deploy_info.txt"
    echo ""
}

# ============================================================
# 5. 为面板申请域名证书（acme.sh + CF DNS）
# ============================================================
setup_acme_cert() {
    print_banner
    echo -e "${BOLD}=== acme.sh + Cloudflare DNS 申请证书 ===${NC}\n"

    # 安装 acme.sh
    if [ "$ACME_INSTALLED" = false ]; then
        read -p "请输入邮箱地址：" ACME_EMAIL
        curl https://get.acme.sh | sh -s email=$ACME_EMAIL >/dev/null 2>&1
        source ~/.bashrc
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt >/dev/null 2>&1
        ACME_INSTALLED=true
        success "acme.sh 已安装"
    else
        success "acme.sh 已安装，跳过"
    fi

    # CF API Key
    security_tip "建议使用 CF API Token（仅 DNS 编辑权限）而非 Global API Key，权限更小更安全"
    echo ""
    echo "1. 使用 Global API Key（权限较大）"
    echo "2. 使用 API Token（推荐，权限更小）"
    read -p "请选择 [1-2，默认 2]：" CF_AUTH_TYPE
    CF_AUTH_TYPE=${CF_AUTH_TYPE:-2}

    if [ "$CF_AUTH_TYPE" = "1" ]; then
        read -p "请输入 Cloudflare Global API Key：" CF_KEY_INPUT
        read -p "请输入 Cloudflare 账号邮箱：" CF_EMAIL_INPUT
        export CF_Key="$CF_KEY_INPUT"
        export CF_Email="$CF_EMAIL_INPUT"
    else
        read -p "请输入 Cloudflare API Token：" CF_TOKEN_INPUT
        export CF_Token="$CF_TOKEN_INPUT"
    fi

    read -p "请输入要申请证书的主域名（如 example.com）：" CERT_DOMAIN

    info "申请通配符证书中..."
    ~/.acme.sh/acme.sh --issue --dns dns_cf \
        -d $CERT_DOMAIN \
        -d *.$CERT_DOMAIN \
        --force 2>/dev/null

    if [ $? -eq 0 ]; then
        mkdir -p /root/cert/$CERT_DOMAIN
        ~/.acme.sh/acme.sh --install-cert -d $CERT_DOMAIN \
            --key-file /root/cert/$CERT_DOMAIN/private.key \
            --fullchain-file /root/cert/$CERT_DOMAIN/cert.crt \
            --reloadcmd "x-ui restart 2>/dev/null; nginx -s reload 2>/dev/null; true"
        chmod -R 755 /root/cert

        save_info "
=== acme.sh 证书 ===
域名：$CERT_DOMAIN
证书路径：/root/cert/$CERT_DOMAIN/cert.crt
私钥路径：/root/cert/$CERT_DOMAIN/private.key
申请时间：$(date)"

        print_line
        success "证书申请完成！"
        info "证书路径：/root/cert/$CERT_DOMAIN/cert.crt"
        info "私钥路径：/root/cert/$CERT_DOMAIN/private.key"
    else
        error "证书申请失败，请检查域名解析和 API Key 是否正确"
    fi
    echo ""
}

# ============================================================
# 6. SSH 安全加固
# ============================================================
ssh_security_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== SSH 安全加固 ===${NC}\n"
        echo "1. 植入 SSH 公钥"
        echo "2. 禁用密码登录"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-2]：" SSH_CHOICE

        case $SSH_CHOICE in
            1) ssh_add_key ;;
            2) ssh_disable_password ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
    done
}

ssh_add_key() {
    echo -e "\n${BOLD}=== 植入 SSH 公钥 ===${NC}\n"
    security_tip "植入公钥后请先验证 Key 登录正常，再执行禁用密码登录操作"
    echo ""
    echo "请粘贴你的 SSH 公钥内容（以 ssh-rsa 或 ssh-ed25519 开头）："
    read -r SSH_PUB_KEY

    if [[ ! "$SSH_PUB_KEY" =~ ^ssh- ]]; then
        error "公钥格式不正确，应以 ssh-rsa 或 ssh-ed25519 开头"
        return
    fi

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "$SSH_PUB_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys

    success "SSH 公钥植入成功！"
    warning "请立即开启新窗口测试 Key 登录是否正常，确认后再禁用密码登录"
    echo ""
}

ssh_disable_password() {
    echo -e "\n${BOLD}=== 禁用密码登录 ===${NC}\n"

    # 检查是否有公钥
    if [ ! -f ~/.ssh/authorized_keys ] || [ ! -s ~/.ssh/authorized_keys ]; then
        error "未检测到 SSH 公钥，禁止执行此操作！"
        error "请先植入 SSH 公钥并验证 Key 登录正常后再禁用密码"
        return
    fi

    security_tip "禁用密码登录后，只能通过 SSH Key 登录"
    security_tip "请确保已在新窗口验证 Key 登录成功，否则将锁死服务器"
    echo ""

    if confirm "确认已验证 Key 登录正常，现在禁用密码登录？"; then
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
        sed -i 's/^#\?KbdInteractiveAuthentication .*/KbdInteractiveAuthentication no/g' /etc/ssh/sshd_config
        sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        success "密码登录已禁用，现在只允许 Key 登录"
    else
        info "操作已取消"
    fi
    echo ""
}

# ============================================================
# 7. 防火墙管理
# ============================================================
firewall_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== 防火墙管理 ===${NC}\n"
        echo "1. 查看当前规则"
        echo "2. 添加放行端口"
        echo "3. 删除端口规则"
        echo "4. 查看防火墙状态"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-4]：" FW_CHOICE

        case $FW_CHOICE in
            1) fw_status ;;
            2)
                read -p "请输入要放行的端口：" FW_PORT
                read -p "协议 (tcp/udp，默认 tcp)：" FW_PROTO
                FW_PROTO=${FW_PROTO:-tcp}
                fw_allow_port $FW_PORT $FW_PROTO
                success "端口 $FW_PORT/$FW_PROTO 已放行"
                ;;
            3)
                read -p "请输入要删除的端口：" FW_PORT
                read -p "协议 (tcp/udp，默认 tcp)：" FW_PROTO
                FW_PROTO=${FW_PROTO:-tcp}
                fw_delete_port $FW_PORT $FW_PROTO
                success "端口 $FW_PORT/$FW_PROTO 规则已删除"
                ;;
            4) fw_status ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
        echo ""
        read -p "按回车键继续..."
    done
}

# ============================================================
# 8. 系统信息与检测
# ============================================================
system_info_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== 系统信息与检测 ===${NC}\n"
        echo "1. 系统信息概览"
        echo "2. 完整硬件信息"
        echo "3. 流媒体解锁检测"
        echo "4. 路由回程测试"
        echo "5. 网速测试"
        echo "6. IP 质量检测"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-6]：" SYS_CHOICE

        case $SYS_CHOICE in
            1) show_system_overview ;;
            2) show_hardware_info ;;
            3) check_streaming ;;
            4) check_route ;;
            5) check_speed ;;
            6) check_ip_quality ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
        echo ""
        read -p "按回车键继续..."
    done
}

show_system_overview() {
    echo -e "\n${BOLD}=== 系统信息概览 ===${NC}\n"
    print_line

    # 系统信息
    echo -e "${CYAN}系统版本：${NC}$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${CYAN}内核版本：${NC}$(uname -r)"
    echo -e "${CYAN}运行时间：${NC}$(uptime -p 2>/dev/null || uptime)"
    echo -e "${CYAN}公网 IP：${NC}$(get_public_ip)"

    print_line

    # CPU
    CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | xargs)
    CPU_CORES=$(nproc)
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")
    echo -e "${CYAN}CPU 型号：${NC}$CPU_MODEL"
    echo -e "${CYAN}CPU 核心：${NC}$CPU_CORES 核"
    echo -e "${CYAN}CPU 使用率：${NC}${CPU_USAGE}%"

    print_line

    # 内存
    MEM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
    MEM_USED=$(free -h | awk '/^Mem:/{print $3}')
    MEM_FREE=$(free -h | awk '/^Mem:/{print $4}')
    SWAP_TOTAL=$(free -h | awk '/^Swap:/{print $2}')
    SWAP_USED=$(free -h | awk '/^Swap:/{print $3}')
    echo -e "${CYAN}内存总量：${NC}$MEM_TOTAL"
    echo -e "${CYAN}内存已用：${NC}$MEM_USED"
    echo -e "${CYAN}内存可用：${NC}$MEM_FREE"
    echo -e "${CYAN}Swap 总量：${NC}$SWAP_TOTAL（已用：$SWAP_USED）"

    print_line

    # 硬盘
    echo -e "${CYAN}硬盘使用情况：${NC}"
    df -h | grep -v tmpfs | grep -v udev | grep -v overlay

    print_line

    # 虚拟化
    VIRT=$(systemd-detect-virt 2>/dev/null || echo "unknown")
    echo -e "${CYAN}虚拟化类型：${NC}$VIRT"
    echo ""
}

show_hardware_info() {
    echo -e "\n${BOLD}=== 完整硬件信息 ===${NC}\n"

    # CPU
    echo -e "${CYAN}=== CPU ===${NC}"
    lscpu 2>/dev/null | grep -E "型号|Model|Core|Thread|Socket|Architecture|Virtualization" || \
        cat /proc/cpuinfo | grep -E "model name|cpu cores|siblings" | sort -u

    echo ""
    echo -e "${CYAN}=== 硬盘 ===${NC}"
    lsblk -d -o NAME,SIZE,TYPE,ROTA 2>/dev/null | grep disk | while read line; do
        ROTA=$(echo $line | awk '{print $4}')
        if [ "$ROTA" = "0" ]; then
            echo "$line → SSD"
        else
            echo "$line → HDD"
        fi
    done

    echo ""
    echo -e "${CYAN}=== 虚拟化 ===${NC}"
    systemd-detect-virt 2>/dev/null || echo "无法检测"

    echo ""
}

check_streaming() {
    echo -e "\n${BOLD}=== 流媒体解锁检测 ===${NC}\n"
    info "调用 RegionRestrictionCheck..."
    bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)
}

check_route() {
    echo -e "\n${BOLD}=== 路由回程测试 ===${NC}\n"

    # 安装 nexttrace
    if ! command -v nexttrace >/dev/null 2>&1; then
        info "安装 nexttrace..."
        curl -sL https://github.com/nxtrace/NTrace-core/raw/main/nt_install.sh | bash >/dev/null 2>&1
    fi

    echo "测试到国内三网回程路由："
    echo ""
    echo -e "${CYAN}=== 电信 (上海 202.96.209.5) ===${NC}"
    nexttrace 202.96.209.5 2>/dev/null || traceroute 202.96.209.5

    echo ""
    echo -e "${CYAN}=== 联通 (北京 210.22.97.1) ===${NC}"
    nexttrace 210.22.97.1 2>/dev/null || traceroute 210.22.97.1

    echo ""
    echo -e "${CYAN}=== 移动 (北京 221.179.155.161) ===${NC}"
    nexttrace 221.179.155.161 2>/dev/null || traceroute 221.179.155.161
}

check_speed() {
    echo -e "\n${BOLD}=== 网速测试 ===${NC}\n"

    if ! command -v speedtest >/dev/null 2>&1; then
        info "安装 speedtest-cli..."
        $PKG_INSTALL speedtest-cli >/dev/null 2>&1
    fi

    speedtest 2>/dev/null || curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}

check_ip_quality() {
    echo -e "\n${BOLD}=== IP 质量检测 ===${NC}\n"
    SERVER_IP=$(get_public_ip)
    info "检测 IP：$SERVER_IP"
    echo ""
    curl -s https://ip.check.place 2>/dev/null || \
    curl -s "https://ipinfo.io/$SERVER_IP/json" 2>/dev/null | python3 -m json.tool 2>/dev/null || \
        info "请访问 https://ip.check.place 手动检测"
}

# ============================================================
# 9. Docker 容器管理
# ============================================================
docker_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== Docker 容器管理 ===${NC}\n"
        echo "1. 查看所有容器状态"
        echo "2. 重启某个容器"
        echo "3. 停止某个容器"
        echo "4. 查看容器日志"
        echo "5. 更新所有镜像"
        echo "6. 一键重启所有服务"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-6]：" DOCKER_CHOICE

        case $DOCKER_CHOICE in
            1)
                echo ""
                docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
                ;;
            2)
                echo ""
                docker ps --format "{{.Names}}"
                echo ""
                read -p "请输入容器名称：" CONTAINER_NAME
                docker restart $CONTAINER_NAME && success "容器 $CONTAINER_NAME 已重启"
                ;;
            3)
                echo ""
                docker ps --format "{{.Names}}"
                echo ""
                read -p "请输入容器名称：" CONTAINER_NAME
                if confirm "确认停止容器 $CONTAINER_NAME？"; then
                    docker stop $CONTAINER_NAME && success "容器 $CONTAINER_NAME 已停止"
                fi
                ;;
            4)
                echo ""
                docker ps --format "{{.Names}}"
                echo ""
                read -p "请输入容器名称：" CONTAINER_NAME
                read -p "显示最后多少行日志（默认 50）：" LOG_LINES
                LOG_LINES=${LOG_LINES:-50}
                docker logs --tail $LOG_LINES $CONTAINER_NAME
                ;;
            5)
                info "更新所有 Docker 镜像..."
                for dir in /opt/*/; do
                    if [ -f "$dir/docker-compose.yml" ]; then
                        info "更新 $dir..."
                        cd $dir && docker compose pull >/dev/null 2>&1 && docker compose up -d >/dev/null 2>&1
                        success "$dir 已更新"
                    fi
                done
                ;;
            6)
                info "重启所有 Docker 服务..."
                for dir in /opt/*/; do
                    if [ -f "$dir/docker-compose.yml" ]; then
                        info "重启 $dir..."
                        cd $dir && docker compose restart >/dev/null 2>&1
                        success "$dir 已重启"
                    fi
                done
                ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
        echo ""
        read -p "按回车键继续..."
    done
}

# ============================================================
# 10. 备份与恢复
# ============================================================
backup_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== 备份与恢复 ===${NC}\n"
        echo "1. 立即备份所有服务数据"
        echo "2. 恢复备份"
        echo "3. 查看现有备份列表"
        echo "4. 设置自动定时备份"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-4]：" BACKUP_CHOICE

        case $BACKUP_CHOICE in
            1) do_backup ;;
            2) do_restore ;;
            3) list_backups ;;
            4) setup_auto_backup ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
        echo ""
        read -p "按回车键继续..."
    done
}

do_backup() {
    echo -e "\n${BOLD}=== 立即备份 ===${NC}\n"
    BACKUP_DIR="/root/backup"
    BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    mkdir -p $BACKUP_DIR

    info "开始备份 /opt 目录..."
    BEFORE=$(df -h / | tail -1 | awk '{print $4}')

    tar -czf $BACKUP_FILE /opt 2>/dev/null
    BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)

    AFTER=$(df -h / | tail -1 | awk '{print $4}')

    success "备份完成！"
    info "备份文件：$BACKUP_FILE"
    info "备份大小：$BACKUP_SIZE"
    echo ""
}

do_restore() {
    echo -e "\n${BOLD}=== 恢复备份 ===${NC}\n"
    BACKUP_DIR="/root/backup"

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        error "没有找到备份文件"
        return
    fi

    list_backups
    echo ""
    read -p "请输入要恢复的备份文件名（含路径）：" RESTORE_FILE

    if [ ! -f "$RESTORE_FILE" ]; then
        error "备份文件不存在"
        return
    fi

    security_tip "恢复操作会覆盖现有数据，此操作不可逆"
    if confirm "确认恢复备份 $RESTORE_FILE？"; then
        info "停止所有 Docker 服务..."
        for dir in /opt/*/; do
            [ -f "$dir/docker-compose.yml" ] && cd $dir && docker compose down >/dev/null 2>&1
        done

        info "恢复备份中..."
        tar -xzf $RESTORE_FILE -C / 2>/dev/null

        info "重启所有 Docker 服务..."
        for dir in /opt/*/; do
            [ -f "$dir/docker-compose.yml" ] && cd $dir && docker compose up -d >/dev/null 2>&1
        done

        success "备份恢复完成！"
    fi
}

list_backups() {
    echo -e "\n${BOLD}=== 现有备份 ===${NC}\n"
    BACKUP_DIR="/root/backup"

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        info "暂无备份文件"
        return
    fi

    ls -lh $BACKUP_DIR/*.tar.gz 2>/dev/null | awk '{print $5, $6, $7, $8, $9}'
}

setup_auto_backup() {
    echo -e "\n${BOLD}=== 设置自动定时备份 ===${NC}\n"
    echo "1. 每天备份一次（凌晨 3 点）"
    echo "2. 每周备份一次（周日凌晨 3 点）"
    read -p "请选择 [1-2]：" AUTO_CHOICE

    read -p "保留最近几份备份（默认 7）：" KEEP_COUNT
    KEEP_COUNT=${KEEP_COUNT:-7}

    BACKUP_SCRIPT="/root/auto_backup.sh"
    cat > $BACKUP_SCRIPT << EOF
#!/bin/bash
BACKUP_DIR="/root/backup"
mkdir -p \$BACKUP_DIR
tar -czf \$BACKUP_DIR/backup_\$(date +%Y%m%d_%H%M%S).tar.gz /opt 2>/dev/null
# 只保留最近 $KEEP_COUNT 份
ls -t \$BACKUP_DIR/backup_*.tar.gz 2>/dev/null | tail -n +$((KEEP_COUNT+1)) | xargs rm -f 2>/dev/null
EOF
    chmod +x $BACKUP_SCRIPT

    case $AUTO_CHOICE in
        1) CRON_EXPR="0 3 * * *" ;;
        2) CRON_EXPR="0 3 * * 0" ;;
        *) CRON_EXPR="0 3 * * *" ;;
    esac

    (crontab -l 2>/dev/null | grep -v "auto_backup"; echo "$CRON_EXPR $BACKUP_SCRIPT") | crontab -
    success "自动备份已设置！保留最近 $KEEP_COUNT 份备份"
    info "Cron 表达式：$CRON_EXPR"
    echo ""
}

# ============================================================
# 11. 安装 WARP
# ============================================================
install_warp() {
    print_banner
    echo -e "${BOLD}=== 安装 WARP（解决送中）===${NC}\n"

    security_tip "安装 WARP 会修改网络配置，建议先备份重要数据"
    echo ""
    echo "WARP 模式说明："
    echo "1. WARP IPv6（推荐）- 为 IPv4 only 机器添加 IPv6，解决送中问题"
    echo "2. WARP IPv4 - 为 IPv6 only 机器添加 IPv4"
    echo "3. 双栈 WARP - 所有流量走 WARP"
    echo ""

    if confirm "确认安装 WARP？"; then
        bash <(curl -fsSL git.io/warp.sh)
    fi
    echo ""
}

# ============================================================
# 12. 网络优化
# ============================================================
network_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== 网络优化 ===${NC}\n"
        echo "1. IPv4 优先"
        echo "2. IPv6 优先"
        echo "3. 禁用 IPv6"
        echo "4. 启用 IPv6"
        echo "5. 切换 DNS"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-5]：" NET_CHOICE

        case $NET_CHOICE in
            1)
                grep -q "^precedence ::ffff:0:0/96  100" /etc/gai.conf || \
                    echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
                success "已设置 IPv4 优先"
                ;;
            2)
                sed -i '/^precedence ::ffff:0:0\/96/d' /etc/gai.conf
                success "已设置 IPv6 优先"
                ;;
            3)
                warning "禁用 IPv6 可能影响部分依赖 IPv6 的服务"
                if confirm "确认禁用 IPv6？"; then
                    grep -q "net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf || \
                        echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
                    sysctl -p >/dev/null 2>&1
                    success "IPv6 已禁用"
                fi
                ;;
            4)
                sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
                sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
                sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
                sysctl -p >/dev/null 2>&1
                success "IPv6 已启用"
                ;;
            5)
                echo ""
                echo "1. Google DNS (8.8.8.8 / 8.8.4.4)"
                echo "2. Cloudflare DNS (1.1.1.1 / 1.0.0.1)"
                echo "3. 自定义 DNS"
                read -p "请选择 [1-3]：" DNS_CHOICE
                case $DNS_CHOICE in
                    1)
                        echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
                        success "已切换到 Google DNS"
                        ;;
                    2)
                        echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" > /etc/resolv.conf
                        success "已切换到 Cloudflare DNS"
                        ;;
                    3)
                        read -p "请输入主 DNS：" DNS1
                        read -p "请输入副 DNS（可选）：" DNS2
                        echo "nameserver $DNS1" > /etc/resolv.conf
                        [ -n "$DNS2" ] && echo "nameserver $DNS2" >> /etc/resolv.conf
                        success "DNS 已更新"
                        ;;
                esac
                ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
        echo ""
        read -p "按回车键继续..."
    done
}

# ============================================================
# 13. 系统清理
# ============================================================
system_clean() {
    print_banner
    echo -e "${BOLD}=== 系统清理 ===${NC}\n"

    BEFORE=$(df -h / | tail -1 | awk '{print $4}')
    info "清理前可用空间：$BEFORE"
    echo ""

    # Docker 清理
    if command -v docker >/dev/null 2>&1; then
        info "清理 Docker 无用镜像和容器..."
        docker system prune -f >/dev/null 2>&1
        success "Docker 清理完成"
    fi

    # apt 清理
    case $PKG_MANAGER in
        apt)
            info "清理 apt 缓存..."
            apt autoremove -y >/dev/null 2>&1
            apt autoclean >/dev/null 2>&1
            success "apt 缓存清理完成"
            ;;
        yum|dnf)
            info "清理 yum/dnf 缓存..."
            $PKG_MANAGER clean all >/dev/null 2>&1
            success "缓存清理完成"
            ;;
    esac

    # 日志清理
    info "清理系统日志..."
    journalctl --vacuum-time=7d >/dev/null 2>&1
    success "系统日志清理完成"

    AFTER=$(df -h / | tail -1 | awk '{print $4}')
    echo ""
    print_line
    info "清理前可用空间：$BEFORE"
    info "清理后可用空间：$AFTER"
    success "系统清理完成！"
    echo ""
    read -p "按回车键继续..."
}

# ============================================================
# 14. 查看部署信息
# ============================================================
show_deploy_info() {
    print_banner
    echo -e "${BOLD}=== 已保存的部署信息 ===${NC}\n"

    if [ ! -f /root/deploy_info.txt ] || [ ! -s /root/deploy_info.txt ]; then
        info "暂无部署信息，部署服务后会自动保存"
    else
        cat /root/deploy_info.txt
    fi
    echo ""
    read -p "按回车键继续..."
}

# ============================================================
# 15. 检查脚本更新
# ============================================================
check_update() {
    print_banner
    echo -e "${BOLD}=== 检查脚本更新 ===${NC}\n"
    info "当前版本：v$VERSION"
    info "检查最新版本..."

    LATEST_VERSION=$(curl -s $GITHUB_RAW 2>/dev/null | grep "^VERSION=" | cut -d'"' -f2)

    if [ -z "$LATEST_VERSION" ]; then
        warning "无法检测最新版本，请检查网络连接"
        echo ""
        read -p "按回车键继续..."
        return
    fi

    if [ "$LATEST_VERSION" = "$VERSION" ]; then
        success "当前已是最新版本 v$VERSION"
    else
        info "发现新版本：v$LATEST_VERSION"
        if confirm "是否更新到 v$LATEST_VERSION？"; then
            SCRIPT_PATH=$(realpath $0)
            curl -s $GITHUB_RAW -o $SCRIPT_PATH
            chmod +x $SCRIPT_PATH
            success "脚本已更新到 v$LATEST_VERSION，请重新运行"
            exit 0
        fi
    fi
    echo ""
    read -p "按回车键继续..."
}

# ============================================================
# 主菜单
# ============================================================
main_menu() {
    while true; do
        print_banner
        echo -e " ${GREEN}一、核心部署${NC}"
        echo -e " ${GREEN}1.${NC}  VPS 初始化加固"
        echo -e " ${GREEN}2.${NC}  部署 WordPress"
        echo -e " ${GREEN}3.${NC}  部署 XBoard"
        echo -e " ${GREEN}4.${NC}  部署 3x-ui"
        echo -e " ${GREEN}5.${NC}  为面板申请域名证书 (acme.sh + CF DNS)"
        echo ""
        echo -e " ${CYAN}二、安全管理${NC}"
        echo -e " ${CYAN}6.${NC}  SSH 安全加固"
        echo -e " ${CYAN}7.${NC}  防火墙管理"
        echo ""
        echo -e " ${YELLOW}三、系统信息与检测${NC}"
        echo -e " ${YELLOW}8.${NC}  系统信息与检测"
        echo ""
        echo -e " ${PURPLE}四、Docker 管理${NC}"
        echo -e " ${PURPLE}9.${NC}  Docker 容器管理"
        echo ""
        echo -e " ${BLUE}五、备份与恢复${NC}"
        echo -e " ${BLUE}10.${NC} 备份与恢复"
        echo ""
        echo -e " ${GREEN}六、网络工具${NC}"
        echo -e " ${GREEN}11.${NC} 安装 WARP（解决送中）"
        echo -e " ${GREEN}12.${NC} 网络优化"
        echo ""
        echo -e " ${CYAN}七、系统维护${NC}"
        echo -e " ${CYAN}13.${NC} 系统清理"
        echo -e " ${CYAN}14.${NC} 查看部署信息"
        echo -e " ${CYAN}15.${NC} 检查脚本更新"
        echo ""
        echo -e " ${RED}0.${NC}  退出"
        print_line
        echo -e "                    ${PURPLE}by noob ra2${NC}"
        print_line
        read -p "请选择操作 [0-15]：" MAIN_CHOICE

        case $MAIN_CHOICE in
            1)  init_vps ;;
            2)  deploy_wordpress ;;
            3)  deploy_xboard ;;
            4)  deploy_3xui ;;
            5)  setup_acme_cert ;;
            6)  ssh_security_menu ;;
            7)  firewall_menu ;;
            8)  system_info_menu ;;
            9)  docker_menu ;;
            10) backup_menu ;;
            11) install_warp ;;
            12) network_menu ;;
            13) system_clean ;;
            14) show_deploy_info ;;
            15) check_update ;;
            0)
                echo -e "\n${GREEN}感谢使用 noob ra2 VPS 工具箱，再见！${NC}\n"
                exit 0
                ;;
            *)
                error "无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# 入口
# ============================================================
check_root
detect_os
check_installed
main_menu
