# shellcheck shell=bash




# ============================================================
# 3. XBoard 菜单
# ============================================================
xboard_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== XBoard ===${NC}\n"
        echo "1. 安装 XBoard"
        echo "2. 卸载 XBoard"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-2]：" XB_CHOICE
        case $XB_CHOICE in
            1) deploy_xboard ;;
            2) uninstall_xboard ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
    done
}

# ============================================================
# 3. 部署 XBoard
# ============================================================
deploy_xboard() {
    print_banner
    echo -e "${BOLD}=== $XB_INSTALL_TITLE ===${NC}\n"

    # 检测是否已安装
    if [ -f /opt/xboard/docker-compose.yml ]; then
        XB_RUNNING=$(docker compose -f /opt/xboard/docker-compose.yml ps --status running 2>/dev/null | grep -c "running" || echo "0")
        if [ "$XB_RUNNING" -gt "0" ]; then
            warning "检测到 XBoard 已安装且正在运行"
        else
            warning "检测到 XBoard 已安装但未运行"
        fi
        echo ""
        echo "1. 重新安装（覆盖现有配置，数据保留）"
        echo "2. 返回"
        read -p "请选择 [1-2]：" REINSTALL_CHOICE
        case $REINSTALL_CHOICE in
            1)
                info "停止现有容器..."
                cd /opt/xboard && docker compose down >/dev/null 2>&1
                ;;
            *)
                info "操作已取消"
                read -p "按回车键继续..."
                return
                ;;
        esac
    fi

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
    warning "$XB_WIZARD_TIP："
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

uninstall_xboard() {
    print_banner
    echo -e "${BOLD}=== $XB_UNINSTALL_TITLE ===${NC}\n"

    if [ ! -d /opt/xboard ]; then
        error "未检测到 XBoard 安装"
        read -p "按回车键继续..."
        return
    fi

    security_tip "卸载操作不可逆，请确认已备份重要数据"
    if ! confirm "确认卸载 XBoard？"; then
        info "操作已取消"
        return
    fi

    info "停止并删除容器..."
    cd /opt/xboard && docker compose down >/dev/null 2>&1
    success "容器已停止"

    if confirm "是否同时删除所有数据（数据库、用户数据）？"; then
        # TODO[v0.3-安全加固]: docker compose down -v 删除数据卷 + rm -rf /opt/xboard 不可逆。建议删除前强制本地备份。详见 SECURITY.md
        cd /opt/xboard && docker compose down -v >/dev/null 2>&1
        rm -rf /opt/xboard
        success "数据已删除"
    else
        rm -f /opt/xboard/docker-compose.yml
        success "$XB_DATA_KEPT"
    fi

    read -p "请输入 XBoard 的域名（没有域名直接回车跳过）：" XB_DOMAIN
    if [ -n "$XB_DOMAIN" ]; then
        rm -f /etc/nginx/sites-enabled/$XB_DOMAIN
        rm -f /etc/nginx/sites-available/$XB_DOMAIN
        rm -f /etc/nginx/conf.d/$XB_DOMAIN
        nginx -t >/dev/null 2>&1 && systemctl reload nginx >/dev/null 2>&1
        success "Nginx 配置已删除"
    fi

    success "XBoard 已卸载完成"
    echo ""
    read -p "按回车键继续..."
}
