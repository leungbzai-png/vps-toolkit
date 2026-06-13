# shellcheck shell=bash

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
    read -p "$(echo -e ${YELLOW}"$DOMAIN_PROMPT："${NC})" HAS_DOMAIN
    if [ "$HAS_DOMAIN" = "y" ] || [ "$HAS_DOMAIN" = "Y" ]; then
        read -p "$DOMAIN_INPUT：" INPUT_DOMAIN
        echo $INPUT_DOMAIN
    else
        echo ""
    fi
}


# ============================================================
# 5. 为面板申请域名证书（acme.sh + CF DNS）
# ============================================================
setup_acme_cert() {
    print_banner
    echo -e "${BOLD}=== $ACME_TITLE ===${NC}\n"

    # 安装 acme.sh
    if [ "$ACME_INSTALLED" = false ]; then
        read -p "$ACME_EMAIL：" ACME_EMAIL_INPUT; ACME_EMAIL=$ACME_EMAIL_INPUT
        # TODO[v0.3-安全加固]: 第三方脚本 curl|sh，未校验来源/完整性。详见 SECURITY.md
        curl https://get.acme.sh | sh -s email=$ACME_EMAIL >/dev/null 2>&1
        source ~/.bashrc
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt >/dev/null 2>&1
        ACME_INSTALLED=true
        success "acme.sh 已安装"
    else
        success "acme.sh 已安装，跳过"
    fi

    # CF API Key
    # TODO[v0.3-安全加固]: CF 凭据通过 export 进入环境并可能落入 ~/.acme.sh 配置。避免回显、避免写入日志，使用最小权限 Token。详见 SECURITY.md
    security_tip "建议使用 CF API Token（仅 DNS 编辑权限）而非 Global API Key，权限更小更安全"
    echo ""
    echo "1. 使用 Global API Key（权限较大）"
    echo "2. 使用 API Token（推荐，权限更小）"
    read -p "请选择 [1-2，默认 2]：" CF_AUTH_TYPE
    CF_AUTH_TYPE=${CF_AUTH_TYPE:-2}

    if [ "$CF_AUTH_TYPE" = "1" ]; then
        read -p "$ACME_CF_KEY_PROMPT：" CF_KEY_INPUT
        read -p "$ACME_CF_EMAIL_PROMPT：" CF_EMAIL_INPUT
        export CF_Key="$CF_KEY_INPUT"
        export CF_Email="$CF_EMAIL_INPUT"
    else
        read -p "$ACME_CF_TOKEN_PROMPT：" CF_TOKEN_INPUT
        export CF_Token="$CF_TOKEN_INPUT"
    fi

    read -p "$ACME_DOMAIN_PROMPT：" CERT_DOMAIN

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
        info "$ACME_CERT_PATH：/root/cert/$CERT_DOMAIN/cert.crt"
        info "$ACME_KEY_PATH：/root/cert/$CERT_DOMAIN/private.key"
    else
        error "证书申请失败，请检查域名解析和 API Key 是否正确"
    fi
    echo ""
}
