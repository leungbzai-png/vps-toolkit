# shellcheck shell=bash


# ============================================================
# 11. 安装 WARP
# ============================================================
install_warp() {
    print_banner
    echo -e "${BOLD}=== $WARP_TITLE ===${NC}\n"

    security_tip "安装 WARP 会修改网络配置，建议先备份重要数据"
    echo ""
    echo "WARP 模式说明："
    echo "1. WARP IPv6（推荐）- 为 IPv4 only 机器添加 IPv6，解决送中问题"
    echo "2. WARP IPv4 - 为 IPv6 only 机器添加 IPv4"
    echo "3. 双栈 WARP - 所有流量走 WARP"
    echo ""

    if confirm "确认安装 WARP？"; then
        # TODO[v0.3-安全加固]: 第三方脚本 bash <(curl git.io/warp.sh)，git.io 短链已停用风险 + 未校验来源。详见 SECURITY.md
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
        echo -e "${BOLD}=== $NET_TITLE ===${NC}\n"
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
                # TODO[v0.3-安全加固]: 直接覆盖 /etc/resolv.conf，可能被 systemd-resolved/NetworkManager 还原且无备份。详见 SECURITY.md
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
                        read -p "$NET_DNS1_PROMPT：" DNS1
                        read -p "$NET_DNS2_PROMPT：" DNS2
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
