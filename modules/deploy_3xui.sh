# shellcheck shell=bash


# ============================================================
# 4. 3x-ui 菜单
# ============================================================
threeui_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== 3x-ui ===${NC}\n"
        echo "1. 安装 3x-ui"
        echo "2. 卸载 3x-ui"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-2]：" UI_CHOICE
        case $UI_CHOICE in
            1) deploy_3xui ;;
            2) uninstall_3xui ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
    done
}


# ============================================================
# 4. 部署 3x-ui
# ============================================================
deploy_3xui() {
    print_banner
    echo -e "${BOLD}=== $UI_INSTALL_TITLE ===${NC}\n"

    # 检测是否已安装
    if command -v x-ui >/dev/null 2>&1 || [ -d /usr/local/x-ui ]; then
        warning "检测到 3x-ui 已安装"
        echo ""
        echo "1. 重新安装（覆盖现有配置）"
        echo "2. 返回"
        read -p "请选择 [1-2]：" REINSTALL_CHOICE
        case $REINSTALL_CHOICE in
            1)
                info "继续重新安装..."
                ;;
            *)
                info "操作已取消"
                read -p "按回车键继续..."
                return
                ;;
        esac
    fi

    info "调用 3x-ui 官方安装脚本..."
    # TODO[v0.3-安全加固]: 第三方脚本 bash <(curl ...) 直接执行，未固定版本/未校验。详见 SECURITY.md
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

    print_line
    success "3x-ui 部署完成！"
    warning "请记录面板账号密码并保存到 /root/deploy_info.txt"
    echo ""
}

uninstall_3xui() {
    print_banner
    echo -e "${BOLD}=== $UI_UNINSTALL_TITLE ===${NC}\n"

    if ! command -v x-ui >/dev/null 2>&1; then
        error "未检测到 3x-ui 安装"
        read -p "按回车键继续..."
        return
    fi

    security_tip "卸载操作不可逆，请确认已备份重要数据"
    if ! confirm "确认卸载 3x-ui？"; then
        info "操作已取消"
        return
    fi

    # TODO[v0.3-安全加固]: 卸载回退到第三方 bash <(curl ...)，同样未校验。详见 SECURITY.md
    x-ui uninstall 2>/dev/null || bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) uninstall

    success "3x-ui 已卸载完成"
    echo ""
    read -p "按回车键继续..."
}
