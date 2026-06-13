# shellcheck shell=bash

# ============================================================
# 安装基础依赖
# ============================================================

# 仅安装基础系统工具（用于初始化加固）
install_base_only() {
    info "更新系统软件包..."
    $PKG_UPDATE >/dev/null 2>&1

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
}

# 安装部署服务所需依赖（Docker + Nginx + Certbot）
install_deploy_deps() {
    install_base_only

    # Docker
    if [ "$DOCKER_INSTALLED" = false ]; then
        info "安装 Docker..."
        # TODO[v0.3-安全加固]: 第三方脚本 curl|sh，未校验来源/完整性。考虑固定版本或改用发行版仓库。详见 SECURITY.md
        curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
        systemctl enable --now docker >/dev/null 2>&1
        $PKG_INSTALL docker-compose-plugin >/dev/null 2>&1
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

# 兼容旧调用（部署函数用）
install_base() {
    install_deploy_deps
}

# ============================================================
# 1. VPS 初始化加固
# ============================================================
init_vps() {
    print_banner
    echo -e "${BOLD}=== $INIT_TITLE ===${NC}\n"

    install_base_only

    # 时区设置
    echo -e "\n${CYAN}请选择时区：${NC}"
    echo "1. 亚洲/东京 (Asia/Tokyo)"
    echo "2. 亚洲/上海 (Asia/Shanghai)"
    echo "3. UTC"
    echo "4. 美国/纽约 (America/New_York)"
    echo "5. 欧洲/伦敦 (Europe/London)"
    echo "6. 自定义"
    read -p "$INIT_TZ_PROMPT：" TZ_CHOICE
    TZ_CHOICE=${TZ_CHOICE:-1}

    case $TZ_CHOICE in
        1) TIMEZONE="Asia/Tokyo" ;;
        2) TIMEZONE="Asia/Shanghai" ;;
        3) TIMEZONE="UTC" ;;
        4) TIMEZONE="America/New_York" ;;
        5) TIMEZONE="Europe/London" ;;
        6) read -p "$INIT_TZ_CUSTOM：" TIMEZONE ;;
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

        info "$INIT_RAM_DETECT：${RAM_MB}MB，$INIT_SWAP_REC：${RECOMMENDED_SWAP}"
        read -p "$INIT_SWAP_PROMPT ${RECOMMENDED_SWAP}：" SWAP_SIZE
        SWAP_SIZE=${SWAP_SIZE:-$RECOMMENDED_SWAP}

        fallocate -l $SWAP_SIZE /swapfile
        chmod 600 /swapfile
        mkswap /swapfile >/dev/null 2>&1
        swapon /swapfile
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
        success "$INIT_SWAP_DONE ${SWAP_SIZE}"
    else
        success "Swap 已配置，跳过"
    fi

    # DNS 优化
    # TODO[v0.3-安全加固]: 直接覆盖 /etc/resolv.conf，会丢失原有配置且可能被 systemd-resolved/NetworkManager 还原。考虑先备份并检测托管方式。详见 SECURITY.md
    echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
    success "DNS 已优化（Google + Cloudflare）"

    # IPv4 优先
    grep -q "^precedence ::ffff:0:0/96  100" /etc/gai.conf 2>/dev/null || \
        echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
    success "IPv4 优先已开启"

    # SSH 端口
    CURRENT_SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -n1)
    CURRENT_SSH_PORT=${CURRENT_SSH_PORT:-22}
    info "$INIT_SSH_CURRENT：$CURRENT_SSH_PORT"
    read -p "$INIT_SSH_PROMPT $CURRENT_SSH_PORT：" SSH_PORT
    SSH_PORT=${SSH_PORT:-$CURRENT_SSH_PORT}

    # 防火墙配置
    case $FIREWALL in
        ufw)
            $PKG_INSTALL ufw >/dev/null 2>&1
            # TODO[v0.3-安全加固]: ufw --force reset 会清空所有已有规则。若用户已有自定义规则会被无声删除，建议改为增量配置或先确认。详见 SECURITY.md
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
            # TODO[v0.3-安全加固]: 直接 sed 改 sshd_config 有锁死风险（端口未放行/配置语法错误）。建议改端口后 sshd -t 校验，并保留回滚窗口。详见 SECURITY.md
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
