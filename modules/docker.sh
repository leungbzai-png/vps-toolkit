# shellcheck shell=bash


# ============================================================
# 9. Docker 容器管理
# ============================================================
docker_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== $DOCKER_TITLE ===${NC}\n"
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
                read -p "$DOCKER_NAME_PROMPT：" CONTAINER_NAME
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
                read -p "$DOCKER_LOG_LINES：" LOG_LINES
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
