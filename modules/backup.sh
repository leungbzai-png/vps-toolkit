# shellcheck shell=bash


# ============================================================
# 10. 备份与恢复
# ============================================================
backup_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== $BACKUP_TITLE ===${NC}\n"
        echo "1. 立即备份所有服务数据"
        echo "2. 恢复备份"
        echo "3. 查看现有备份列表"
        echo "4. 设置自动定时备份"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-4]：" BACKUP_CHOICE

        case $BACKUP_CHOICE in
            1) do_backup ;;
            2) do_restore ;;
            3) list_backups ;;
            4) setup_auto_backup ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
        echo ""
        read -p "按回车键继续..."
    done
}

do_backup() {
    echo -e "\n${BOLD}=== $BACKUP_NOW ===${NC}\n"
    BACKUP_DIR="/root/backup"
    BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    mkdir -p $BACKUP_DIR

    info "开始备份 /opt 目录..."
    BEFORE=$(df -h / | tail -1 | awk '{print $4}')

    tar -czf $BACKUP_FILE /opt 2>/dev/null
    BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)

    AFTER=$(df -h / | tail -1 | awk '{print $4}')

    success "备份完成！"
    info "$BACKUP_FILE：$BACKUP_FILE"
    info "$BACKUP_SIZE：$BACKUP_SIZE"
    echo ""
}

do_restore() {
    echo -e "\n${BOLD}=== $BACKUP_RESTORE ===${NC}\n"
    BACKUP_DIR="/root/backup"

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        error "没有找到备份文件"
        return
    fi

    list_backups
    echo ""
    read -p "$BACKUP_RESTORE_FILE：" RESTORE_FILE

    if [ ! -f "$RESTORE_FILE" ]; then
        error "备份文件不存在"
        return
    fi

    security_tip "恢复操作会覆盖现有数据，此操作不可逆"
    if confirm "确认恢复备份 $RESTORE_FILE？"; then
        info "停止所有 Docker 服务..."
        for dir in /opt/*/; do
            [ -f "$dir/docker-compose.yml" ] && cd $dir && docker compose down >/dev/null 2>&1
        done

        info "恢复备份中..."
        tar -xzf $RESTORE_FILE -C / 2>/dev/null

        info "重启所有 Docker 服务..."
        for dir in /opt/*/; do
            [ -f "$dir/docker-compose.yml" ] && cd $dir && docker compose up -d >/dev/null 2>&1
        done

        success "备份恢复完成！"
    fi
}

list_backups() {
    echo -e "\n${BOLD}=== 现有备份 ===${NC}\n"
    BACKUP_DIR="/root/backup"

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        info "暂无备份文件"
        return
    fi

    ls -lh $BACKUP_DIR/*.tar.gz 2>/dev/null | awk '{print $5, $6, $7, $8, $9}'
}

setup_auto_backup() {
    echo -e "\n${BOLD}=== 设置自动定时备份 ===${NC}\n"
    echo "1. 每天备份一次（凌晨 3 点）"
    echo "2. 每周备份一次（周日凌晨 3 点）"
    read -p "请选择 [1-2]：" AUTO_CHOICE

    read -p "$BACKUP_KEEP_PROMPT：" KEEP_COUNT
    KEEP_COUNT=${KEEP_COUNT:-7}

    BACKUP_SCRIPT="/root/auto_backup.sh"
    cat > $BACKUP_SCRIPT << EOF
BACKUP_DIR="/root/backup"
mkdir -p \$BACKUP_DIR
tar -czf \$BACKUP_DIR/backup_\$(date +%Y%m%d_%H%M%S).tar.gz /opt 2>/dev/null
# 只保留最近 $KEEP_COUNT 份
ls -t \$BACKUP_DIR/backup_*.tar.gz 2>/dev/null | tail -n +$((KEEP_COUNT+1)) | xargs rm -f 2>/dev/null
EOF
    chmod +x $BACKUP_SCRIPT

    case $AUTO_CHOICE in
        1) CRON_EXPR="0 3 * * *" ;;
        2) CRON_EXPR="0 3 * * 0" ;;
        *) CRON_EXPR="0 3 * * *" ;;
    esac

    (crontab -l 2>/dev/null | grep -v "auto_backup"; echo "$CRON_EXPR $BACKUP_SCRIPT") | crontab -
    success "自动备份已设置！保留最近 $KEEP_COUNT 份备份"
    info "Cron 表达式：$CRON_EXPR"
    echo ""
}
