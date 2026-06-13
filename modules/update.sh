# shellcheck shell=bash


# ============================================================
# 14. 查看部署信息
# ============================================================
show_deploy_info() {
    print_banner
    echo -e "${BOLD}=== $DEPLOY_TITLE ===${NC}\n"

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
    echo -e "${BOLD}=== $UPDATE_TITLE ===${NC}\n"
    info "$UPDATE_CURRENT：v$VERSION"
    info "检查最新版本..."

    LATEST_VERSION=$(curl -s $GITHUB_RAW 2>/dev/null | grep "^VERSION=" | cut -d'"' -f2)

    if [ -z "$LATEST_VERSION" ]; then
        warning "无法检测最新版本，请检查网络连接"
        echo ""
        read -p "按回车键继续..."
        return
    fi

    if [ "$LATEST_VERSION" = "$VERSION" ]; then
        success "$UPDATE_LATEST v$VERSION"
    else
        info "$UPDATE_FOUND：v$LATEST_VERSION"
        if confirm "是否更新到 v$LATEST_VERSION？"; then
            SCRIPT_PATH=$(realpath $0)
            curl -s $GITHUB_RAW -o $SCRIPT_PATH
            chmod +x $SCRIPT_PATH
            success "$UPDATE_DONE v$LATEST_VERSION"
            exit 0
        fi
    fi
    echo ""
    read -p "按回车键继续..."
}
