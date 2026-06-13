# shellcheck shell=bash

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
# 7. 防火墙管理
# ============================================================
firewall_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== $FW_TITLE ===${NC}\n"
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
                read -p "$FW_PORT_PROMPT：" FW_PORT
                read -p "$FW_PROTO_PROMPT：" FW_PROTO
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
