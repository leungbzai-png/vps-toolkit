# shellcheck shell=bash


# ============================================================
# 6. SSH 安全加固
# ============================================================
ssh_security_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== $SSH_TITLE ===${NC}\n"
        echo "1. 植入 SSH 公钥"
        echo "2. 禁用密码登录"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-2]：" SSH_CHOICE

        case $SSH_CHOICE in
            1) ssh_add_key ;;
            2) ssh_disable_password ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
    done
}

ssh_add_key() {
    echo -e "\n${BOLD}=== $SSH_KEY_TITLE ===${NC}\n"
    security_tip "植入公钥后请先验证 Key 登录正常，再执行禁用密码登录操作"
    echo ""
    echo "$SSH_KEY_PROMPT："
    read -r SSH_PUB_KEY

    if [[ ! "$SSH_PUB_KEY" =~ ^ssh- ]]; then
        error "公钥格式不正确，应以 ssh-rsa 或 ssh-ed25519 开头"
        return
    fi

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "$SSH_PUB_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys

    success "SSH 公钥植入成功！"
    warning "请立即开启新窗口测试 Key 登录是否正常，确认后再禁用密码登录"
    echo ""
}

ssh_disable_password() {
    echo -e "\n${BOLD}=== $SSH_DISABLE_TITLE ===${NC}\n"

    # 检查是否有公钥
    if [ ! -f ~/.ssh/authorized_keys ] || [ ! -s ~/.ssh/authorized_keys ]; then
        error "未检测到 SSH 公钥，禁止执行此操作！"
        error "请先植入 SSH 公钥并验证 Key 登录正常后再禁用密码"
        return
    fi

    security_tip "禁用密码登录后，只能通过 SSH Key 登录"
    security_tip "请确保已在新窗口验证 Key 登录成功，否则将锁死服务器"
    echo ""

    if confirm "确认已验证 Key 登录正常，现在禁用密码登录？"; then
        # TODO[v0.3-安全加固]: 直接 sed 改 sshd_config 并重启；若公钥无效会锁死服务器。建议 sshd -t 校验 + 回滚窗口。详见 SECURITY.md
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
        sed -i 's/^#\?KbdInteractiveAuthentication .*/KbdInteractiveAuthentication no/g' /etc/ssh/sshd_config
        sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        success "密码登录已禁用，现在只允许 Key 登录"
    else
        info "操作已取消"
    fi
    echo ""
}
