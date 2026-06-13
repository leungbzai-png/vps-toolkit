# shellcheck shell=bash


# ============================================================
# 8. 系统信息与检测
# ============================================================
system_info_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== $SYS_TITLE ===${NC}\n"
        echo "1. 系统信息概览"
        echo "2. 完整硬件信息"
        echo "3. 流媒体解锁检测"
        echo "4. 路由回程测试"
        echo "5. 网速测试"
        echo "6. IP 质量检测"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-6]：" SYS_CHOICE

        case $SYS_CHOICE in
            1) show_system_overview ;;
            2) show_hardware_info ;;
            3) check_streaming ;;
            4) check_route ;;
            5) check_speed ;;
            6) check_ip_quality ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
        echo ""
        read -p "按回车键继续..."
    done
}

show_system_overview() {
    echo -e "\n${BOLD}=== 系统信息概览 ===${NC}\n"
    print_line

    # 系统信息
    echo -e "${CYAN}系统版本：${NC}$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${CYAN}内核版本：${NC}$(uname -r)"
    echo -e "${CYAN}运行时间：${NC}$(uptime -p 2>/dev/null || uptime)"
    echo -e "${CYAN}公网 IP：${NC}$(get_public_ip)"

    print_line

    # CPU
    CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | xargs)
    CPU_CORES=$(nproc)
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")
    echo -e "${CYAN}CPU 型号：${NC}$CPU_MODEL"
    echo -e "${CYAN}CPU 核心：${NC}$CPU_CORES 核"
    echo -e "${CYAN}CPU 使用率：${NC}${CPU_USAGE}%"

    print_line

    # 内存
    MEM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
    MEM_USED=$(free -h | awk '/^Mem:/{print $3}')
    MEM_FREE=$(free -h | awk '/^Mem:/{print $4}')
    SWAP_TOTAL=$(free -h | awk '/^Swap:/{print $2}')
    SWAP_USED=$(free -h | awk '/^Swap:/{print $3}')
    echo -e "${CYAN}内存总量：${NC}$MEM_TOTAL"
    echo -e "${CYAN}内存已用：${NC}$MEM_USED"
    echo -e "${CYAN}内存可用：${NC}$MEM_FREE"
    echo -e "${CYAN}Swap 总量：${NC}$SWAP_TOTAL（已用：$SWAP_USED）"

    print_line

    # 硬盘
    echo -e "${CYAN}硬盘使用情况：${NC}"
    df -h | grep -v tmpfs | grep -v udev | grep -v overlay

    print_line

    # 虚拟化
    VIRT=$(systemd-detect-virt 2>/dev/null || echo "unknown")
    echo -e "${CYAN}虚拟化类型：${NC}$VIRT"
    echo ""
}

show_hardware_info() {
    echo -e "\n${BOLD}=== 完整硬件信息 ===${NC}\n"

    # CPU
    echo -e "${CYAN}=== CPU ===${NC}"
    lscpu 2>/dev/null | grep -E "型号|Model|Core|Thread|Socket|Architecture|Virtualization" || \
        cat /proc/cpuinfo | grep -E "model name|cpu cores|siblings" | sort -u

    echo ""
    echo -e "${CYAN}=== 硬盘 ===${NC}"
    lsblk -d -o NAME,SIZE,TYPE,ROTA 2>/dev/null | grep disk | while read line; do
        ROTA=$(echo $line | awk '{print $4}')
        if [ "$ROTA" = "0" ]; then
            echo "$line → SSD"
        else
            echo "$line → HDD"
        fi
    done

    echo ""
    echo -e "${CYAN}=== 虚拟化 ===${NC}"
    systemd-detect-virt 2>/dev/null || echo "无法检测"

    echo ""
}

check_streaming() {
    echo -e "\n${BOLD}=== 流媒体解锁检测 ===${NC}\n"
    info "调用 RegionRestrictionCheck..."
    # TODO[v0.3-安全加固]: 第三方检测脚本 bash <(curl ...)，未校验来源。详见 SECURITY.md
    bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)
}

check_route() {
    echo -e "\n${BOLD}=== 路由回程测试 ===${NC}\n"

    # 安装 nexttrace
    if ! command -v nexttrace >/dev/null 2>&1; then
        info "安装 nexttrace..."
        # TODO[v0.3-安全加固]: 第三方脚本 curl|bash，未校验来源。详见 SECURITY.md
        curl -sL https://github.com/nxtrace/NTrace-core/raw/main/nt_install.sh | bash >/dev/null 2>&1
    fi

    echo "测试到国内三网回程路由："
    echo ""
    echo -e "${CYAN}=== 电信 (上海 202.96.209.5) ===${NC}"
    nexttrace 202.96.209.5 2>/dev/null || traceroute 202.96.209.5

    echo ""
    echo -e "${CYAN}=== 联通 (北京 210.22.97.1) ===${NC}"
    nexttrace 210.22.97.1 2>/dev/null || traceroute 210.22.97.1

    echo ""
    echo -e "${CYAN}=== 移动 (北京 221.179.155.161) ===${NC}"
    nexttrace 221.179.155.161 2>/dev/null || traceroute 221.179.155.161
}

check_speed() {
    echo -e "\n${BOLD}=== 网速测试 ===${NC}\n"

    if ! command -v speedtest >/dev/null 2>&1; then
        info "安装 speedtest-cli..."
        $PKG_INSTALL speedtest-cli >/dev/null 2>&1
    fi

    # TODO[v0.3-安全加固]: 回退执行第三方 speedtest.py（curl|python3），未校验来源。详见 SECURITY.md
    speedtest 2>/dev/null || curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}

check_ip_quality() {
    echo -e "\n${BOLD}=== IP 质量检测 ===${NC}\n"
    SERVER_IP=$(get_public_ip)
    info "检测 IP：$SERVER_IP"
    echo ""
    # TODO[v0.3-安全加固]: 将本机 IP 提交给第三方服务（ip.check.place / ipinfo.io）进行查询，注意隐私。详见 SECURITY.md
    curl -s https://ip.check.place 2>/dev/null || \
    curl -s "https://ipinfo.io/$SERVER_IP/json" 2>/dev/null | python3 -m json.tool 2>/dev/null || \
        info "请访问 https://ip.check.place 手动检测"
}
