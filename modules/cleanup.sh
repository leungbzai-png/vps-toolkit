# shellcheck shell=bash


# ============================================================
# 13. 系统清理
# ============================================================
system_clean() {
    print_banner
    echo -e "${BOLD}=== $CLEAN_TITLE ===${NC}\n"

    BEFORE=$(df -h / | tail -1 | awk '{print $4}')
    info "$CLEAN_BEFORE：$BEFORE"
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
    info "$CLEAN_AFTER：$AFTER"
    success "系统清理完成！"
    echo ""
    read -p "按回车键继续..."
}
