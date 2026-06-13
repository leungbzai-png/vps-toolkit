# shellcheck shell=bash



# ============================================================
# 2. WordPress 菜单
# ============================================================
wordpress_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== WordPress ===${NC}\n"
        echo "1. 安装 WordPress"
        echo "2. 卸载 WordPress"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-2]：" WP_CHOICE
        case $WP_CHOICE in
            1) deploy_wordpress ;;
            2) uninstall_wordpress ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
    done
}

# ============================================================
# 2. 部署 WordPress
# ============================================================
deploy_wordpress() {
    print_banner
    echo -e "${BOLD}=== $WP_INSTALL_TITLE ===${NC}\n"

    # 检测是否已安装
    if [ -f /opt/wordpress/docker-compose.yml ]; then
        WP_RUNNING=$(docker compose -f /opt/wordpress/docker-compose.yml ps --status running 2>/dev/null | grep -c "running" || echo "0")
        if [ "$WP_RUNNING" -gt "0" ]; then
            warning "检测到 WordPress 已安装且正在运行"
        else
            warning "检测到 WordPress 已安装但未运行"
        fi
        echo ""
        echo "1. 重新安装（覆盖现有配置，数据保留）"
        echo "2. 返回"
        read -p "请选择 [1-2]：" REINSTALL_CHOICE
        case $REINSTALL_CHOICE in
            1)
                info "停止现有容器..."
                cd /opt/wordpress && docker compose down >/dev/null 2>&1
                ;;
            *)
                info "操作已取消"
                read -p "$MSG_PRESS_ENTER"
                return
                ;;
        esac
    fi

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
    info "$WP_ACCESS：$ACCESS"
    warning "账号信息已保存到 /root/deploy_info.txt"
    echo ""
}

uninstall_wordpress() {
    print_banner
    echo -e "${BOLD}=== $WP_UNINSTALL_TITLE ===${NC}\n"

    if [ ! -d /opt/wordpress ]; then
        error "未检测到 WordPress 安装"
        read -p "按回车键继续..."
        return
    fi

    security_tip "卸载操作不可逆，请确认已备份重要数据"
    if ! confirm "确认卸载 WordPress？"; then
        info "操作已取消"
        return
    fi

    info "停止并删除容器..."
    cd /opt/wordpress && docker compose down >/dev/null 2>&1
    success "容器已停止"

    if confirm "是否同时删除所有数据（数据库、文章、媒体文件）？"; then
        # TODO[v0.3-安全加固]: docker compose down -v 删除数据卷 + rm -rf /opt/wordpress 不可逆。建议删除前强制本地备份。详见 SECURITY.md
        cd /opt/wordpress && docker compose down -v >/dev/null 2>&1
        rm -rf /opt/wordpress
        success "数据已删除"
    else
        rm -f /opt/wordpress/docker-compose.yml
        success "容器已删除，数据目录保留在 /opt/wordpress"
    fi

    read -p "$WP_DOMAIN_PROMPT：" WP_DOMAIN
    if [ -n "$WP_DOMAIN" ]; then
        rm -f /etc/nginx/sites-enabled/$WP_DOMAIN
        rm -f /etc/nginx/sites-available/$WP_DOMAIN
        rm -f /etc/nginx/conf.d/$WP_DOMAIN
        nginx -t >/dev/null 2>&1 && systemctl reload nginx >/dev/null 2>&1
        success "Nginx 配置已删除"
    fi

    success "WordPress 已卸载完成"
    echo ""
    read -p "按回车键继续..."
}
