#!/bin/bash
# ============================================================
#        noob ra2 VPS 工具箱
#        by noob ra2
#        版本：1.0.0
# ============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# 版本
VERSION="1.0.0"
SCRIPT_VERSION="1.0.0"
GITHUB_RAW="https://raw.githubusercontent.com/leungbzai-png/vps-toolkit/refs/heads/main/setup.sh"

# ============================================================
# 语言包 / Language Pack
# ============================================================
select_language() {
    clear
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║         noob ra2 VPS Toolkit             ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
    echo "  1. 简体中文"
    echo "  2. 繁體中文"
    echo "  3. English"
    echo "  4. 日本語"
    echo ""
    read -p "  请选择语言 / Select Language / 言語 [1-4, default 1]: " LANG_CHOICE
    LANG_CHOICE=${LANG_CHOICE:-1}
    case $LANG_CHOICE in
        2) LANG_SET="zh_tw" ;;
        3) LANG_SET="en" ;;
        4) LANG_SET="ja" ;;
        *) LANG_SET="zh_cn" ;;
    esac
    load_language
}

load_language() {
    case $LANG_SET in
        zh_tw)
            # 繁體中文
            MSG_SUCCESS="成功"
            MSG_ERROR="錯誤"
            MSG_WARNING="警告"
            MSG_INFO="資訊"
            MSG_SECURITY="安全提示"
            MSG_CONFIRM_YN="(y/n)"
            MSG_PRESS_ENTER="按 Enter 繼續..."
            MSG_CANCEL="$MSG_CANCEL"
            MSG_BACK="返回主選單"
            MSG_INVALID="無效選項，請重新選擇"
            MSG_GOODBYE_1="感謝使用 noob ra2 VPS 工具箱"
            MSG_GOODBYE_2="願你的伺服器永遠穩如磐石 🚀"
            # Banner
            BANNER_TITLE="noob ra2 VPS 工具箱"
            # Main menu categories
            CAT_DEPLOY="一、核心部署"
            CAT_SECURITY="二、安全管理"
            CAT_SYSINFO="三、系統資訊與檢測"
            CAT_DOCKER="四、Docker 管理"
            CAT_BACKUP="五、備份與恢復"
            CAT_NETWORK="六、網路工具"
            CAT_MAINTAIN="七、系統維護"
            # Main menu items
            MENU_1="VPS 初始化加固"
            MENU_2="部署 WordPress"
            MENU_3="部署 XBoard"
            MENU_4="部署 3x-ui"
            MENU_5="為面板申請域名憑證 (acme.sh + CF DNS)"
            MENU_6="SSH 安全加固"
            MENU_7="防火牆管理"
            MENU_8="系統資訊與檢測"
            MENU_9="Docker 容器管理"
            MENU_10="備份與恢復"
            MENU_11="安裝 WARP（解決送中）"
            MENU_12="網路優化"
            MENU_13="系統清理"
            MENU_14="查看部署資訊"
            MENU_15="檢查腳本更新"
            MENU_0="退出"
            MENU_PROMPT="請選擇操作 [0-15]"
            # Init VPS
            INIT_TITLE="VPS 初始化加固"
            INIT_TZ_TITLE="請選擇時區"
            INIT_TZ_1="亞洲/東京"
            INIT_TZ_2="亞洲/上海"
            INIT_TZ_3="UTC"
            INIT_TZ_4="美國/紐約"
            INIT_TZ_5="歐洲/倫敦"
            INIT_TZ_6="自訂"
            INIT_TZ_PROMPT="請選擇 [1-6，預設 1]"
            INIT_TZ_CUSTOM="請輸入時區（如 Asia/Singapore）"
            INIT_TZ_DONE="時區已設定為"
            INIT_BBR_DONE="BBR 加速已開啟"
            INIT_BBR_SKIP="BBR 加速已開啟，跳過"
            INIT_RAM_DETECT="檢測到 RAM"
            INIT_SWAP_REC="推薦 Swap"
            INIT_SWAP_PROMPT="請輸入 Swap 大小（直接回車使用推薦值）"
            INIT_SWAP_DONE="Swap 已設定"
            INIT_SWAP_SKIP="Swap 已設定，跳過"
            INIT_DNS_DONE="DNS 已優化（Google + Cloudflare）"
            INIT_IPV4_DONE="IPv4 優先已開啟"
            INIT_SSH_CURRENT="目前 SSH 連接埠"
            INIT_SSH_PROMPT="請輸入新 SSH 連接埠（直接回車保持）"
            INIT_SSH_TIP="修改 SSH 連接埠前請確認防火牆已放行新連接埠"
            INIT_SSH_CONFIRM="確認修改 SSH 連接埠為"
            INIT_SSH_DONE="SSH 連接埠已改為"
            INIT_SSH_WARNING="請開啟新視窗用連接埠驗證能否登入，確認後再關閉目前視窗！"
            INIT_DONE="VPS 初始化加固完成！"
            # WordPress
            WP_INSTALL_TITLE="安裝 WordPress"
            WP_RUNNING="檢測到 WordPress 已安裝且正在運行"
            WP_STOPPED="檢測到 WordPress 已安裝但未運行"
            WP_REINSTALL="重新安裝（覆蓋現有設定，資料保留）"
            WP_REINSTALL_STOP="停止現有容器..."
            WP_STARTING="啟動 WordPress 容器..."
            WP_STARTED="WordPress 容器已啟動"
            WP_DONE="$WP_DONE"
            WP_ACCESS="訪問地址"
            WP_SAVED="帳號資訊已儲存到 /root/deploy_info.txt"
            WP_UNINSTALL_TITLE="解除安裝 WordPress"
            WP_NOT_FOUND="未檢測到 WordPress 安裝"
            WP_UNINSTALL_TIP="解除安裝操作不可逆，請確認已備份重要資料"
            WP_UNINSTALL_CONFIRM="確認解除安裝 WordPress？"
            WP_STOP_CONTAINER="停止並刪除容器..."
            WP_CONTAINER_STOPPED="$WP_CONTAINER_STOPPED"
            WP_DELETE_DATA="是否同時刪除所有資料（資料庫、文章、媒體檔案）？"
            WP_DATA_DELETED="資料已刪除"
            WP_DATA_KEPT="容器已刪除，資料目錄保留在 /opt/wordpress"
            WP_DOMAIN_PROMPT="請輸入 WordPress 的網域（沒有網域直接回車跳過）"
            WP_NGINX_DELETED="Nginx 設定已刪除"
            WP_UNINSTALL_DONE="WordPress 已解除安裝完成"
            # XBoard
            XB_INSTALL_TITLE="安裝 XBoard"
            XB_RUNNING="檢測到 XBoard 已安裝且正在運行"
            XB_STOPPED="檢測到 XBoard 已安裝但未運行"
            XB_WAIT_DB="等待資料庫初始化..."
            XB_WIZARD_TIP="即將進入 XBoard 安裝精靈，請按以下資訊填寫"
            XB_DONE="$XB_DONE"
            XB_UNINSTALL_TITLE="解除安裝 XBoard"
            XB_NOT_FOUND="未檢測到 XBoard 安裝"
            XB_UNINSTALL_CONFIRM="確認解除安裝 XBoard？"
            XB_DELETE_DATA="是否同時刪除所有資料（資料庫、用戶資料）？"
            XB_UNINSTALL_DONE="XBoard 已解除安裝完成"
            # 3xui
            UI_INSTALL_TITLE="安裝 3x-ui"
            UI_RUNNING="檢測到 3x-ui 已安裝"
            UI_DONE="$UI_DONE"
            UI_SAVE_TIP="請記錄面板帳號密碼並儲存到 /root/deploy_info.txt"
            UI_UNINSTALL_TITLE="解除安裝 3x-ui"
            UI_NOT_FOUND="未檢測到 3x-ui 安裝"
            UI_UNINSTALL_CONFIRM="確認解除安裝 3x-ui？"
            UI_UNINSTALL_DONE="3x-ui 已解除安裝完成"
            # SSH
            SSH_TITLE="SSH 安全加固"
            SSH_KEY_TITLE="植入 SSH 公鑰"
            SSH_KEY_TIP="植入後請先驗證 Key 登入正常，再執行禁用密碼登入操作"
            SSH_KEY_PROMPT="請貼上你的 SSH 公鑰內容（以 ssh-rsa 或 ssh-ed25519 開頭）"
            SSH_KEY_ERR="公鑰格式不正確，應以 ssh-rsa 或 ssh-ed25519 開頭"
            SSH_KEY_DONE="SSH 公鑰植入成功！"
            SSH_KEY_WARN="請立即開啟新視窗測試 Key 登入是否正常，確認後再禁用密碼登入"
            SSH_DISABLE_TITLE="禁用密碼登入"
            SSH_NO_KEY="未檢測到 SSH 公鑰，禁止執行此操作！請先植入 SSH 公鑰並驗證 Key 登入正常後再禁用密碼"
            SSH_DISABLE_TIP1="禁用密碼登入後，只能透過 SSH Key 登入"
            SSH_DISABLE_TIP2="請確保已在新視窗驗證 Key 登入成功，否則將鎖死伺服器"
            SSH_DISABLE_CONFIRM="確認已驗證 Key 登入正常，現在禁用密碼登入？"
            SSH_DISABLE_DONE="密碼登入已禁用，現在只允許 Key 登入"
            # Firewall
            FW_TITLE="防火牆管理"
            FW_VIEW="查看目前規則"
            FW_ADD="新增放行連接埠"
            FW_DEL="刪除連接埠規則"
            FW_STATUS="查看防火牆狀態"
            FW_PORT_PROMPT="請輸入連接埠"
            FW_PROTO_PROMPT="協定 (tcp/udp，預設 tcp)"
            FW_ADD_DONE="連接埠已放行"
            FW_DEL_DONE="連接埠規則已刪除"
            # System info
            SYS_TITLE="系統資訊與檢測"
            SYS_OVERVIEW="系統資訊概覽"
            SYS_HW="完整硬體資訊"
            SYS_STREAM="串流媒體解鎖檢測"
            SYS_ROUTE="路由回程測試"
            SYS_SPEED="網速測試"
            SYS_IP="IP 品質檢測"
            # Docker
            DOCKER_TITLE="Docker 容器管理"
            DOCKER_LIST="查看所有容器狀態"
            DOCKER_RESTART="重新啟動某個容器"
            DOCKER_STOP="停止某個容器"
            DOCKER_LOG="查看容器日誌"
            DOCKER_UPDATE="更新所有映像"
            DOCKER_RESTART_ALL="一鍵重新啟動所有服務"
            DOCKER_NAME_PROMPT="請輸入容器名稱"
            DOCKER_STOP_CONFIRM="確認停止容器"
            DOCKER_LOG_LINES="顯示最後幾行日誌（預設 50）"
            # Backup
            BACKUP_TITLE="備份與恢復"
            BACKUP_NOW="立即備份所有服務資料"
            BACKUP_RESTORE="恢復備份"
            BACKUP_LIST="查看現有備份清單"
            BACKUP_AUTO="設定自動定時備份"
            BACKUP_DONE="備份完成！"
            BACKUP_FILE="備份檔案"
            BACKUP_SIZE="備份大小"
            BACKUP_RESTORE_TIP="恢復會覆蓋現有資料，請確認後執行"
            BACKUP_RESTORE_CONFIRM="確認恢復備份"
            BACKUP_RESTORE_FILE="請輸入要恢復的備份檔案名稱（含路徑）"
            BACKUP_NOT_FOUND="備份檔案不存在"
            BACKUP_NO_BACKUP="暫無備份檔案"
            BACKUP_STOP_ALL="停止所有 Docker 服務..."
            BACKUP_RESTORE_ING="恢復備份中..."
            BACKUP_RESTART_ALL="重新啟動所有 Docker 服務..."
            BACKUP_RESTORE_DONE="備份恢復完成！"
            BACKUP_AUTO_DAILY="每天備份一次（凌晨 3 點）"
            BACKUP_AUTO_WEEKLY="每週備份一次（週日凌晨 3 點）"
            BACKUP_KEEP_PROMPT="保留最近幾份備份（預設 7）"
            BACKUP_AUTO_DONE="自動備份已設定！保留最近"
            BACKUP_AUTO_DONE2="份備份"
            # WARP
            WARP_TITLE="安裝 WARP（解決送中）"
            WARP_TIP="安裝 WARP 會修改網路設定，建議先備份重要資料"
            WARP_CONFIRM="確認安裝 WARP？"
            # Network
            NET_TITLE="網路優化"
            NET_IPV4="IPv4 優先"
            NET_IPV6="IPv6 優先"
            NET_DIS_IPV6="$NET_DIS_IPV6"
            NET_EN_IPV6="啟用 IPv6"
            NET_DNS="切換 DNS"
            NET_DIS_IPV6_TIP="禁用 IPv6 可能影響部分服務"
            NET_DIS_IPV6_CONFIRM="確認禁用 IPv6？"
            NET_DNS_CUSTOM="自訂 DNS"
            NET_DNS1_PROMPT="請輸入主 DNS"
            NET_DNS2_PROMPT="請輸入副 DNS（可選）"
            # Clean
            CLEAN_TITLE="系統清理"
            CLEAN_BEFORE="清理前可用空間"
            CLEAN_DOCKER="清理 Docker 無用映像和容器..."
            CLEAN_DOCKER_DONE="$CLEAN_DOCKER_DONE"
            CLEAN_PKG="清理套件快取..."
            CLEAN_PKG_DONE="套件快取清理完成"
            CLEAN_LOG="清理系統日誌..."
            CLEAN_LOG_DONE="系統日誌清理完成"
            CLEAN_AFTER="清理後可用空間"
            CLEAN_DONE="系統清理完成！"
            # Deploy info
            DEPLOY_TITLE="已儲存的部署資訊"
            DEPLOY_EMPTY="暫無部署資訊，部署服務後會自動儲存"
            # Update
            UPDATE_TITLE="檢查腳本更新"
            UPDATE_CURRENT="目前版本"
            UPDATE_CHECKING="檢查最新版本..."
            UPDATE_FAIL="無法檢測最新版本，請檢查網路連線"
            UPDATE_LATEST="目前已是最新版本"
            UPDATE_FOUND="發現新版本"
            UPDATE_CONFIRM="是否更新到"
            UPDATE_DONE="腳本已更新，請重新執行"
            # Domain
            DOMAIN_PROMPT="是否為此服務設定網域？(y/n)"
            DOMAIN_INPUT="請輸入網域（如 example.com，不含 www）"
            # ACME
            ACME_TITLE="acme.sh + Cloudflare DNS 申請憑證"
            ACME_EMAIL="請輸入電子郵件地址"
            ACME_CF_TIP="建議使用 CF API Token（僅 DNS 編輯權限）而非 Global API Key"
            ACME_CF_GLOBAL="使用 Global API Key（權限較大）"
            ACME_CF_TOKEN="使用 API Token（推薦，權限較小）"
            ACME_CF_KEY_PROMPT="請輸入 Cloudflare Global API Key"
            ACME_CF_EMAIL_PROMPT="請輸入 Cloudflare 帳號電子郵件"
            ACME_CF_TOKEN_PROMPT="請輸入 Cloudflare API Token"
            ACME_DOMAIN_PROMPT="請輸入要申請憑證的主網域（如 example.com）"
            ACME_ISSUING="申請通配符憑證中..."
            ACME_DONE="憑證申請完成！"
            ACME_CERT_PATH="憑證路徑"
            ACME_KEY_PATH="私鑰路徑"
            ACME_FAIL="憑證申請失敗，請檢查網域解析和 API Key 是否正確"
            ;;
        en)
            # English
            MSG_SUCCESS="Success"
            MSG_ERROR="Error"
            MSG_WARNING="Warning"
            MSG_INFO="Info"
            MSG_SECURITY="Security Notice"
            MSG_CONFIRM_YN="(y/n)"
            MSG_PRESS_ENTER="Press Enter to continue..."
            MSG_CANCEL="Operation cancelled"
            MSG_BACK="Back to main menu"
            MSG_INVALID="Invalid option, please try again"
            MSG_GOODBYE_1="Thank you for using noob ra2 VPS Toolkit"
            MSG_GOODBYE_2="May your servers run forever stable 🚀"
            BANNER_TITLE="noob ra2 VPS Toolkit"
            CAT_DEPLOY="I. Core Deployment"
            CAT_SECURITY="II. Security"
            CAT_SYSINFO="III. System Info & Diagnostics"
            CAT_DOCKER="IV. Docker Management"
            CAT_BACKUP="V. Backup & Restore"
            CAT_NETWORK="VI. Network Tools"
            CAT_MAINTAIN="VII. Maintenance"
            MENU_1="VPS Initialization & Hardening"
            MENU_2="Deploy WordPress"
            MENU_3="Deploy XBoard"
            MENU_4="Deploy 3x-ui"
            MENU_5="Request SSL Certificate (acme.sh + CF DNS)"
            MENU_6="SSH Security Hardening"
            MENU_7="Firewall Management"
            MENU_8="System Info & Diagnostics"
            MENU_9="Docker Container Management"
            MENU_10="Backup & Restore"
            MENU_11="Install WARP"
            MENU_12="Network Optimization"
            MENU_13="System Cleanup"
            MENU_14="View Deployment Info"
            MENU_15="Check for Updates"
            MENU_0="Exit"
            MENU_PROMPT="Select an option [0-15]"
            INIT_TITLE="VPS Initialization & Hardening"
            INIT_TZ_TITLE="Select Timezone"
            INIT_TZ_1="Asia/Tokyo"
            INIT_TZ_2="Asia/Shanghai"
            INIT_TZ_3="UTC"
            INIT_TZ_4="America/New_York"
            INIT_TZ_5="Europe/London"
            INIT_TZ_6="Custom"
            INIT_TZ_PROMPT="Select [1-6, default 1]"
            INIT_TZ_CUSTOM="Enter timezone (e.g. Asia/Singapore)"
            INIT_TZ_DONE="Timezone set to"
            INIT_BBR_DONE="BBR acceleration enabled"
            INIT_BBR_SKIP="BBR already enabled, skipping"
            INIT_RAM_DETECT="Detected RAM"
            INIT_SWAP_REC="Recommended Swap"
            INIT_SWAP_PROMPT="Enter Swap size (press Enter for recommended)"
            INIT_SWAP_DONE="Swap configured"
            INIT_SWAP_SKIP="Swap already configured, skipping"
            INIT_DNS_DONE="DNS optimized (Google + Cloudflare)"
            INIT_IPV4_DONE="IPv4 priority enabled"
            INIT_SSH_CURRENT="Current SSH port"
            INIT_SSH_PROMPT="Enter new SSH port (press Enter to keep current)"
            INIT_SSH_TIP="Ensure firewall allows new SSH port before changing"
            INIT_SSH_CONFIRM="Confirm changing SSH port to"
            INIT_SSH_DONE="SSH port changed to"
            INIT_SSH_WARNING="Open a new window to verify login with new port before closing this one!"
            INIT_DONE="VPS initialization complete!"
            WP_INSTALL_TITLE="Install WordPress"
            WP_RUNNING="WordPress is already installed and running"
            WP_STOPPED="WordPress is installed but not running"
            WP_REINSTALL="Reinstall (overwrite config, keep data)"
            WP_REINSTALL_STOP="Stopping existing containers..."
            WP_STARTING="Starting WordPress containers..."
            WP_STARTED="WordPress containers started"
            WP_DONE="WordPress deployed successfully!"
            WP_ACCESS="Access URL"
            WP_SAVED="Credentials saved to /root/deploy_info.txt"
            WP_UNINSTALL_TITLE="Uninstall WordPress"
            WP_NOT_FOUND="WordPress installation not found"
            WP_UNINSTALL_TIP="This operation is irreversible. Please backup your data first"
            WP_UNINSTALL_CONFIRM="Confirm uninstall WordPress?"
            WP_STOP_CONTAINER="Stopping and removing containers..."
            WP_CONTAINER_STOPPED="Containers stopped"
            WP_DELETE_DATA="Delete all data (database, posts, media files)?"
            WP_DATA_DELETED="Data deleted"
            WP_DATA_KEPT="Containers removed, data kept at /opt/wordpress"
            WP_DOMAIN_PROMPT="Enter WordPress domain (press Enter to skip)"
            WP_NGINX_DELETED="Nginx config removed"
            WP_UNINSTALL_DONE="WordPress uninstalled successfully"
            XB_INSTALL_TITLE="Install XBoard"
            XB_RUNNING="XBoard is already installed and running"
            XB_STOPPED="XBoard is installed but not running"
            XB_WAIT_DB="Waiting for database initialization..."
            XB_WIZARD_TIP="Starting XBoard setup wizard. Please use the following credentials"
            XB_DONE="XBoard deployed successfully!"
            XB_UNINSTALL_TITLE="Uninstall XBoard"
            XB_NOT_FOUND="XBoard installation not found"
            XB_UNINSTALL_CONFIRM="Confirm uninstall XBoard?"
            XB_DELETE_DATA="Delete all data (database, user data)?"
            XB_UNINSTALL_DONE="XBoard uninstalled successfully"
            UI_INSTALL_TITLE="Install 3x-ui"
            UI_RUNNING="3x-ui is already installed"
            UI_DONE="3x-ui deployed successfully!"
            UI_SAVE_TIP="Please save your panel credentials to /root/deploy_info.txt"
            UI_UNINSTALL_TITLE="Uninstall 3x-ui"
            UI_NOT_FOUND="3x-ui installation not found"
            UI_UNINSTALL_CONFIRM="Confirm uninstall 3x-ui?"
            UI_UNINSTALL_DONE="3x-ui uninstalled successfully"
            SSH_TITLE="SSH Security Hardening"
            SSH_KEY_TITLE="Add SSH Public Key"
            SSH_KEY_TIP="Verify key login works before disabling password auth"
            SSH_KEY_PROMPT="Paste your SSH public key (starts with ssh-rsa or ssh-ed25519)"
            SSH_KEY_ERR="Invalid key format. Must start with ssh-rsa or ssh-ed25519"
            SSH_KEY_DONE="SSH public key added successfully!"
            SSH_KEY_WARN="Open a new window to verify key login before disabling password auth"
            SSH_DISABLE_TITLE="Disable Password Login"
            SSH_NO_KEY="No SSH key found. Add a key and verify login before disabling passwords"
            SSH_DISABLE_TIP1="After disabling, only SSH key login will be allowed"
            SSH_DISABLE_TIP2="Ensure key login works in a new window first, or you will be locked out"
            SSH_DISABLE_CONFIRM="Confirm key login works? Disable password login now?"
            SSH_DISABLE_DONE="Password login disabled. SSH key only"
            FW_TITLE="Firewall Management"
            FW_VIEW="View current rules"
            FW_ADD="Allow port"
            FW_DEL="Remove port rule"
            FW_STATUS="View firewall status"
            FW_PORT_PROMPT="Enter port number"
            FW_PROTO_PROMPT="Protocol (tcp/udp, default tcp)"
            FW_ADD_DONE="Port allowed"
            FW_DEL_DONE="Port rule removed"
            SYS_TITLE="System Info & Diagnostics"
            SYS_OVERVIEW="System Overview"
            SYS_HW="Full Hardware Info"
            SYS_STREAM="Streaming Unlock Test"
            SYS_ROUTE="Route Trace"
            SYS_SPEED="Speed Test"
            SYS_IP="IP Quality Check"
            DOCKER_TITLE="Docker Container Management"
            DOCKER_LIST="View all containers"
            DOCKER_RESTART="Restart a container"
            DOCKER_STOP="Stop a container"
            DOCKER_LOG="View container logs"
            DOCKER_UPDATE="Update all images"
            DOCKER_RESTART_ALL="Restart all services"
            DOCKER_NAME_PROMPT="Enter container name"
            DOCKER_STOP_CONFIRM="Confirm stop container"
            DOCKER_LOG_LINES="Show last N lines (default 50)"
            BACKUP_TITLE="Backup & Restore"
            BACKUP_NOW="Backup all service data now"
            BACKUP_RESTORE="Restore backup"
            BACKUP_LIST="List existing backups"
            BACKUP_AUTO="Set up automatic backup"
            BACKUP_DONE="Backup complete!"
            BACKUP_FILE="Backup file"
            BACKUP_SIZE="Backup size"
            BACKUP_RESTORE_TIP="Restore will overwrite existing data. Please confirm"
            BACKUP_RESTORE_CONFIRM="Confirm restore backup"
            BACKUP_RESTORE_FILE="Enter backup file path to restore"
            BACKUP_NOT_FOUND="Backup file not found"
            BACKUP_NO_BACKUP="No backup files found"
            BACKUP_STOP_ALL="Stopping all Docker services..."
            BACKUP_RESTORE_ING="Restoring backup..."
            BACKUP_RESTART_ALL="Restarting all Docker services..."
            BACKUP_RESTORE_DONE="Backup restored successfully!"
            BACKUP_AUTO_DAILY="Daily backup (3 AM)"
            BACKUP_AUTO_WEEKLY="Weekly backup (Sunday 3 AM)"
            BACKUP_KEEP_PROMPT="Number of backups to keep (default 7)"
            BACKUP_AUTO_DONE="Auto backup configured! Keeping last"
            BACKUP_AUTO_DONE2="backups"
            WARP_TITLE="Install WARP"
            WARP_TIP="WARP will modify network settings. Backup important data first"
            WARP_CONFIRM="Confirm install WARP?"
            NET_TITLE="Network Optimization"
            NET_IPV4="Prefer IPv4"
            NET_IPV6="Prefer IPv6"
            NET_DIS_IPV6="Disable IPv6"
            NET_EN_IPV6="Enable IPv6"
            NET_DNS="Switch DNS"
            NET_DIS_IPV6_TIP="Disabling IPv6 may affect some services"
            NET_DIS_IPV6_CONFIRM="Confirm disable IPv6?"
            NET_DNS_CUSTOM="Custom DNS"
            NET_DNS1_PROMPT="Enter primary DNS"
            NET_DNS2_PROMPT="Enter secondary DNS (optional)"
            CLEAN_TITLE="System Cleanup"
            CLEAN_BEFORE="Free space before"
            CLEAN_DOCKER="Cleaning unused Docker images and containers..."
            CLEAN_DOCKER_DONE="Docker cleanup complete"
            CLEAN_PKG="Cleaning package cache..."
            CLEAN_PKG_DONE="Package cache cleaned"
            CLEAN_LOG="Cleaning system logs..."
            CLEAN_LOG_DONE="System logs cleaned"
            CLEAN_AFTER="Free space after"
            CLEAN_DONE="System cleanup complete!"
            DEPLOY_TITLE="Saved Deployment Info"
            DEPLOY_EMPTY="No deployment info yet. Will be saved after deploying services"
            UPDATE_TITLE="Check for Updates"
            UPDATE_CURRENT="Current version"
            UPDATE_CHECKING="Checking for latest version..."
            UPDATE_FAIL="Unable to check for updates. Please check network connection"
            UPDATE_LATEST="Already on the latest version"
            UPDATE_FOUND="New version available"
            UPDATE_CONFIRM="Update to"
            UPDATE_DONE="Script updated. Please restart"
            DOMAIN_PROMPT="Configure domain for this service? (y/n)"
            DOMAIN_INPUT="Enter domain (e.g. example.com, without www)"
            ACME_TITLE="SSL Certificate (acme.sh + Cloudflare DNS)"
            ACME_EMAIL="Enter your email address"
            ACME_CF_TIP="Recommended: Use CF API Token (DNS edit only) instead of Global API Key"
            ACME_CF_GLOBAL="Use Global API Key (full access)"
            ACME_CF_TOKEN="Use API Token (recommended, limited scope)"
            ACME_CF_KEY_PROMPT="Enter Cloudflare Global API Key"
            ACME_CF_EMAIL_PROMPT="Enter Cloudflare account email"
            ACME_CF_TOKEN_PROMPT="Enter Cloudflare API Token"
            ACME_DOMAIN_PROMPT="Enter domain to issue certificate for (e.g. example.com)"
            ACME_ISSUING="Requesting wildcard certificate..."
            ACME_DONE="Certificate issued successfully!"
            ACME_CERT_PATH="Certificate path"
            ACME_KEY_PATH="Private key path"
            ACME_FAIL="Certificate request failed. Check DNS and API credentials"
            ;;
        ja)
            # 日本語
            MSG_SUCCESS="成功"
            MSG_ERROR="エラー"
            MSG_WARNING="警告"
            MSG_INFO="情報"
            MSG_SECURITY="セキュリティ注意"
            MSG_CONFIRM_YN="(y/n)"
            MSG_PRESS_ENTER="Enterキーで続行..."
            MSG_CANCEL="操作をキャンセルしました"
            MSG_BACK="メインメニューに戻る"
            MSG_INVALID="無効な選択です。再度お試しください"
            MSG_GOODBYE_1="noob ra2 VPS ツールキットをご利用いただきありがとうございます"
            MSG_GOODBYE_2="サーバーが永遠に安定して動作しますように 🚀"
            BANNER_TITLE="noob ra2 VPS ツールキット"
            CAT_DEPLOY="一、コアデプロイ"
            CAT_SECURITY="二、セキュリティ管理"
            CAT_SYSINFO="三、システム情報と診断"
            CAT_DOCKER="四、Docker管理"
            CAT_BACKUP="五、バックアップと復元"
            CAT_NETWORK="六、ネットワークツール"
            CAT_MAINTAIN="七、システムメンテナンス"
            MENU_1="VPS初期化とセキュリティ強化"
            MENU_2="WordPress デプロイ"
            MENU_3="XBoard デプロイ"
            MENU_4="3x-ui デプロイ"
            MENU_5="SSL証明書取得 (acme.sh + CF DNS)"
            MENU_6="SSHセキュリティ強化"
            MENU_7="ファイアウォール管理"
            MENU_8="システム情報と診断"
            MENU_9="Dockerコンテナ管理"
            MENU_10="バックアップと復元"
            MENU_11="WARPインストール"
            MENU_12="ネットワーク最適化"
            MENU_13="システムクリーンアップ"
            MENU_14="デプロイ情報を表示"
            MENU_15="アップデートを確認"
            MENU_0="終了"
            MENU_PROMPT="操作を選択してください [0-15]"
            INIT_TITLE="VPS初期化とセキュリティ強化"
            INIT_TZ_TITLE="タイムゾーンを選択"
            INIT_TZ_1="アジア/東京"
            INIT_TZ_2="アジア/上海"
            INIT_TZ_3="UTC"
            INIT_TZ_4="アメリカ/ニューヨーク"
            INIT_TZ_5="ヨーロッパ/ロンドン"
            INIT_TZ_6="カスタム"
            INIT_TZ_PROMPT="選択してください [1-6、デフォルト 1]"
            INIT_TZ_CUSTOM="タイムゾーンを入力（例：Asia/Singapore）"
            INIT_TZ_DONE="タイムゾーンを設定しました"
            INIT_BBR_DONE="BBRアクセラレーションを有効化しました"
            INIT_BBR_SKIP="BBRは既に有効です。スキップします"
            INIT_RAM_DETECT="検出されたRAM"
            INIT_SWAP_REC="推奨Swapサイズ"
            INIT_SWAP_PROMPT="Swapサイズを入力（Enterで推奨値を使用）"
            INIT_SWAP_DONE="Swapを設定しました"
            INIT_SWAP_SKIP="Swapは既に設定されています。スキップします"
            INIT_DNS_DONE="DNSを最適化しました（Google + Cloudflare）"
            INIT_IPV4_DONE="IPv4優先を有効化しました"
            INIT_SSH_CURRENT="現在のSSHポート"
            INIT_SSH_PROMPT="新しいSSHポートを入力（Enterで現在のポートを維持）"
            INIT_SSH_TIP="変更前にファイアウォールで新しいSSHポートを許可してください"
            INIT_SSH_CONFIRM="SSHポートをに変更しますか"
            INIT_SSH_DONE="SSHポートをに変更しました"
            INIT_SSH_WARNING="変更後は新しいウィンドウで新ポートへのログインを確認してから、このウィンドウを閉じてください！"
            INIT_DONE="VPS初期化完了！"
            WP_INSTALL_TITLE="WordPress インストール"
            WP_RUNNING="WordPressは既にインストールされ、実行中です"
            WP_STOPPED="WordPressはインストールされていますが、停止しています"
            WP_REINSTALL="再インストール（設定を上書き、データは保持）"
            WP_REINSTALL_STOP="既存のコンテナを停止中..."
            WP_STARTING="WordPressコンテナを起動中..."
            WP_STARTED="WordPressコンテナが起動しました"
            WP_DONE="WordPressのデプロイが完了しました！"
            WP_ACCESS="アクセスURL"
            WP_SAVED="認証情報を /root/deploy_info.txt に保存しました"
            WP_UNINSTALL_TITLE="WordPress アンインストール"
            WP_NOT_FOUND="WordPressのインストールが見つかりません"
            WP_UNINSTALL_TIP="この操作は元に戻せません。重要なデータをバックアップしてください"
            WP_UNINSTALL_CONFIRM="WordPressをアンインストールしますか？"
            WP_STOP_CONTAINER="コンテナを停止・削除中..."
            WP_CONTAINER_STOPPED="コンテナを停止しました"
            WP_DELETE_DATA="全データを削除しますか（データベース、記事、メディアファイル）？"
            WP_DATA_DELETED="データを削除しました"
            WP_DATA_KEPT="コンテナを削除しました。データは /opt/wordpress に保持されています"
            WP_DOMAIN_PROMPT="WordPressのドメインを入力（スキップする場合はEnter）"
            WP_NGINX_DELETED="Nginx設定を削除しました"
            WP_UNINSTALL_DONE="WordPressのアンインストールが完了しました"
            XB_INSTALL_TITLE="XBoard インストール"
            XB_RUNNING="XBoardは既にインストールされ、実行中です"
            XB_STOPPED="XBoardはインストールされていますが、停止しています"
            XB_WAIT_DB="データベースの初期化を待っています..."
            XB_WIZARD_TIP="XBoardセットアップウィザードを開始します。以下の情報を使用してください"
            XB_DONE="XBoardのデプロイが完了しました！"
            XB_UNINSTALL_TITLE="XBoard アンインストール"
            XB_NOT_FOUND="XBoardのインストールが見つかりません"
            XB_UNINSTALL_CONFIRM="XBoardをアンインストールしますか？"
            XB_DELETE_DATA="全データを削除しますか（データベース、ユーザーデータ）？"
            XB_UNINSTALL_DONE="XBoardのアンインストールが完了しました"
            UI_INSTALL_TITLE="3x-ui インストール"
            UI_RUNNING="3x-uiは既にインストールされています"
            UI_DONE="3x-uiのデプロイが完了しました！"
            UI_SAVE_TIP="パネルの認証情報を /root/deploy_info.txt に保存してください"
            UI_UNINSTALL_TITLE="3x-ui アンインストール"
            UI_NOT_FOUND="3x-uiのインストールが見つかりません"
            UI_UNINSTALL_CONFIRM="3x-uiをアンインストールしますか？"
            UI_UNINSTALL_DONE="3x-uiのアンインストールが完了しました"
            SSH_TITLE="SSHセキュリティ強化"
            SSH_KEY_TITLE="SSH公開鍵の追加"
            SSH_KEY_TIP="パスワード認証を無効にする前に、鍵でのログインを確認してください"
            SSH_KEY_PROMPT="SSH公開鍵を貼り付けてください（ssh-rsaまたはssh-ed25519で始まる）"
            SSH_KEY_ERR="無効な鍵形式です。ssh-rsaまたはssh-ed25519で始まる必要があります"
            SSH_KEY_DONE="SSH公開鍵を追加しました！"
            SSH_KEY_WARN="新しいウィンドウで鍵でのログインを確認してから、パスワード認証を無効にしてください"
            SSH_DISABLE_TITLE="パスワードログインの無効化"
            SSH_NO_KEY="SSH鍵が見つかりません。鍵を追加してログインを確認してから、パスワードを無効にしてください"
            SSH_DISABLE_TIP1="無効化後は、SSH鍵でのログインのみ許可されます"
            SSH_DISABLE_TIP2="新しいウィンドウで鍵ログインが機能することを確認してください。そうしないとサーバーにアクセスできなくなります"
            SSH_DISABLE_CONFIRM="鍵ログインが機能することを確認しましたか？パスワードログインを無効にしますか？"
            SSH_DISABLE_DONE="パスワードログインを無効化しました。SSH鍵のみ許可"
            FW_TITLE="ファイアウォール管理"
            FW_VIEW="現在のルールを表示"
            FW_ADD="ポートを許可"
            FW_DEL="ポートルールを削除"
            FW_STATUS="ファイアウォールの状態を表示"
            FW_PORT_PROMPT="ポート番号を入力"
            FW_PROTO_PROMPT="プロトコル (tcp/udp、デフォルト tcp)"
            FW_ADD_DONE="ポートを許可しました"
            FW_DEL_DONE="ポートルールを削除しました"
            SYS_TITLE="システム情報と診断"
            SYS_OVERVIEW="システム概要"
            SYS_HW="詳細なハードウェア情報"
            SYS_STREAM="ストリーミング解除テスト"
            SYS_ROUTE="ルートトレース"
            SYS_SPEED="スピードテスト"
            SYS_IP="IP品質チェック"
            DOCKER_TITLE="Dockerコンテナ管理"
            DOCKER_LIST="全コンテナを表示"
            DOCKER_RESTART="コンテナを再起動"
            DOCKER_STOP="コンテナを停止"
            DOCKER_LOG="コンテナログを表示"
            DOCKER_UPDATE="全イメージを更新"
            DOCKER_RESTART_ALL="全サービスを再起動"
            DOCKER_NAME_PROMPT="コンテナ名を入力"
            DOCKER_STOP_CONFIRM="コンテナを停止しますか"
            DOCKER_LOG_LINES="表示する最後の行数（デフォルト50）"
            BACKUP_TITLE="バックアップと復元"
            BACKUP_NOW="全サービスデータを今すぐバックアップ"
            BACKUP_RESTORE="バックアップを復元"
            BACKUP_LIST="既存のバックアップを一覧表示"
            BACKUP_AUTO="自動バックアップを設定"
            BACKUP_DONE="バックアップ完了！"
            BACKUP_FILE="バックアップファイル"
            BACKUP_SIZE="バックアップサイズ"
            BACKUP_RESTORE_TIP="復元すると既存のデータが上書きされます。確認してください"
            BACKUP_RESTORE_CONFIRM="バックアップを復元しますか"
            BACKUP_RESTORE_FILE="復元するバックアップファイルのパスを入力"
            BACKUP_NOT_FOUND="バックアップファイルが見つかりません"
            BACKUP_NO_BACKUP="バックアップファイルがありません"
            BACKUP_STOP_ALL="全Dockerサービスを停止中..."
            BACKUP_RESTORE_ING="バックアップを復元中..."
            BACKUP_RESTART_ALL="全Dockerサービスを再起動中..."
            BACKUP_RESTORE_DONE="バックアップの復元が完了しました！"
            BACKUP_AUTO_DAILY="毎日バックアップ（午前3時）"
            BACKUP_AUTO_WEEKLY="毎週バックアップ（日曜午前3時）"
            BACKUP_KEEP_PROMPT="保持するバックアップ数（デフォルト7）"
            BACKUP_AUTO_DONE="自動バックアップを設定しました！最新"
            BACKUP_AUTO_DONE2="件を保持"
            WARP_TITLE="WARPインストール"
            WARP_TIP="WARPはネットワーク設定を変更します。重要なデータをバックアップしてください"
            WARP_CONFIRM="WARPをインストールしますか？"
            NET_TITLE="ネットワーク最適化"
            NET_IPV4="IPv4を優先"
            NET_IPV6="IPv6を優先"
            NET_DIS_IPV6="IPv6を無効化"
            NET_EN_IPV6="IPv6を有効化"
            NET_DNS="DNSを切り替え"
            NET_DIS_IPV6_TIP="IPv6を無効化すると一部のサービスに影響する場合があります"
            NET_DIS_IPV6_CONFIRM="IPv6を無効化しますか？"
            NET_DNS_CUSTOM="カスタムDNS"
            NET_DNS1_PROMPT="プライマリDNSを入力"
            NET_DNS2_PROMPT="セカンダリDNSを入力（任意）"
            CLEAN_TITLE="システムクリーンアップ"
            CLEAN_BEFORE="クリーンアップ前の空き容量"
            CLEAN_DOCKER="未使用のDockerイメージとコンテナを削除中..."
            CLEAN_DOCKER_DONE="Dockerのクリーンアップ完了"
            CLEAN_PKG="パッケージキャッシュを削除中..."
            CLEAN_PKG_DONE="パッケージキャッシュを削除しました"
            CLEAN_LOG="システムログを削除中..."
            CLEAN_LOG_DONE="システムログを削除しました"
            CLEAN_AFTER="クリーンアップ後の空き容量"
            CLEAN_DONE="システムクリーンアップ完了！"
            DEPLOY_TITLE="保存されたデプロイ情報"
            DEPLOY_EMPTY="デプロイ情報がありません。サービスをデプロイすると自動保存されます"
            UPDATE_TITLE="アップデートを確認"
            UPDATE_CURRENT="現在のバージョン"
            UPDATE_CHECKING="最新バージョンを確認中..."
            UPDATE_FAIL="アップデートを確認できません。ネットワーク接続を確認してください"
            UPDATE_LATEST="最新バージョンです"
            UPDATE_FOUND="新しいバージョンが見つかりました"
            UPDATE_CONFIRM="にアップデートしますか"
            UPDATE_DONE="スクリプトを更新しました。再起動してください"
            DOMAIN_PROMPT="このサービスにドメインを設定しますか？(y/n)"
            DOMAIN_INPUT="ドメインを入力してください（例：example.com、wwwなし）"
            ACME_TITLE="SSL証明書取得 (acme.sh + Cloudflare DNS)"
            ACME_EMAIL="メールアドレスを入力"
            ACME_CF_TIP="推奨：Global API KeyではなくCF APIトークン（DNS編集のみ）を使用してください"
            ACME_CF_GLOBAL="Global API Keyを使用（フルアクセス）"
            ACME_CF_TOKEN="APIトークンを使用（推奨、限定スコープ）"
            ACME_CF_KEY_PROMPT="Cloudflare Global API Keyを入力"
            ACME_CF_EMAIL_PROMPT="Cloudflareアカウントのメールアドレスを入力"
            ACME_CF_TOKEN_PROMPT="Cloudflare APIトークンを入力"
            ACME_DOMAIN_PROMPT="証明書を取得するメインドメインを入力（例：example.com）"
            ACME_ISSUING="ワイルドカード証明書を取得中..."
            ACME_DONE="証明書の取得が完了しました！"
            ACME_CERT_PATH="証明書パス"
            ACME_KEY_PATH="秘密鍵パス"
            ACME_FAIL="証明書の取得に失敗しました。DNSとAPIキーを確認してください"
            ;;
        *)
            # 简体中文（默认）
            MSG_SUCCESS="成功"
            MSG_ERROR="错误"
            MSG_WARNING="警告"
            MSG_INFO="信息"
            MSG_SECURITY="安全提示"
            MSG_CONFIRM_YN="(y/n)"
            MSG_PRESS_ENTER="按回车键继续..."
            MSG_CANCEL="操作已取消"
            MSG_BACK="返回主菜单"
            MSG_INVALID="$MSG_INVALID"
            MSG_GOODBYE_1="感谢使用 noob ra2 VPS 工具箱"
            MSG_GOODBYE_2="愿你的服务器永远稳如磐石 🚀"
            BANNER_TITLE="noob ra2 VPS 工具箱"
            CAT_DEPLOY="一、核心部署"
            CAT_SECURITY="二、安全管理"
            CAT_SYSINFO="三、系統資訊與檢測"
            CAT_DOCKER="四、Docker 管理"
            CAT_BACKUP="$CAT_BACKUP"
            CAT_NETWORK="六、網路工具"
            CAT_MAINTAIN="七、系統維護"
            MENU_1="VPS 初始化加固"
            MENU_2="部署 WordPress"
            MENU_3="部署 XBoard"
            MENU_4="部署 3x-ui"
            MENU_5="為面板申請域名憑證 (acme.sh + CF DNS)"
            MENU_6="SSH 安全加固"
            MENU_7="防火牆管理"
            MENU_8="系統資訊與檢測"
            MENU_9="Docker 容器管理"
            MENU_10="$MENU_10"
            MENU_11="$MENU_11"
            MENU_12="$MENU_12"
            MENU_13="$MENU_13"
            MENU_14="$MENU_14"
            MENU_15="$MENU_15"
            MENU_0="退出"
            MENU_PROMPT="请选择操作 [0-15]"
            INIT_TITLE="VPS 初始化加固"
            INIT_TZ_TITLE="请选择时区"
            INIT_TZ_1="$INIT_TZ_1"
            INIT_TZ_2="$INIT_TZ_2"
            INIT_TZ_3="UTC"
            INIT_TZ_4="$INIT_TZ_3"
            INIT_TZ_5="$INIT_TZ_4"
            INIT_TZ_6="$INIT_TZ_6"
            INIT_TZ_PROMPT="请选择 [1-6，默认 1]"
            INIT_TZ_CUSTOM="请输入时区（如 Asia/Singapore）"
            INIT_TZ_DONE="时区已设置为"
            INIT_BBR_DONE="BBR 加速已開啟"
            INIT_BBR_SKIP="BBR 加速已開啟，跳過"
            INIT_RAM_DETECT="检测到 RAM"
            INIT_SWAP_REC="推荐 Swap"
            INIT_SWAP_PROMPT="请输入 Swap 大小（直接回车使用推荐值）"
            INIT_SWAP_DONE="Swap 已配置"
            INIT_SWAP_SKIP="Swap 已設定，跳過"
            INIT_DNS_DONE="DNS 已優化（Google + Cloudflare）"
            INIT_IPV4_DONE="IPv4 優先已開啟"
            INIT_SSH_CURRENT="当前 SSH 端口"
            INIT_SSH_PROMPT="请输入新 SSH 端口（直接回车保持当前端口）"
            INIT_SSH_TIP="修改 SSH 端口前请确认防火墙已放行新端口"
            INIT_SSH_CONFIRM="确认修改 SSH 端口为"
            INIT_SSH_DONE="SSH 端口已改为"
            INIT_SSH_WARNING="请开启新窗口用新端口验证能否登录，确认后再关闭当前窗口！"
            INIT_DONE="VPS 初始化加固完成！"
            WP_INSTALL_TITLE="安装 WordPress"
            WP_RUNNING="$WP_RUNNING"
            WP_STOPPED="$WP_STOPPED"
            WP_REINSTALL="$WP_REINSTALL"
            WP_REINSTALL_STOP="$WP_REINSTALL_STOP"
            WP_STARTING="$WP_STARTING"
            WP_STARTED="$WP_STARTED"
            WP_DONE="WordPress 部署完成！"
            WP_ACCESS="访问地址"
            WP_SAVED="$WP_SAVED"
            WP_UNINSTALL_TITLE="卸载 WordPress"
            WP_NOT_FOUND="$WP_NOT_FOUND"
            WP_UNINSTALL_TIP="$WP_UNINSTALL_TIP"
            WP_UNINSTALL_CONFIRM="$WP_UNINSTALL_CONFIRM"
            WP_STOP_CONTAINER="$WP_STOP_CONTAINER"
            WP_CONTAINER_STOPPED="容器已停止"
            WP_DELETE_DATA="$WP_DELETE_DATA"
            WP_DATA_DELETED="$WP_DATA_DELETED"
            WP_DATA_KEPT="$WP_DATA_KEPT"
            WP_DOMAIN_PROMPT="请输入 WordPress 的域名（没有域名直接回车跳过）"
            WP_NGINX_DELETED="$WP_NGINX_DELETED"
            WP_UNINSTALL_DONE="$WP_UNINSTALL_DONE"
            XB_INSTALL_TITLE="安装 XBoard"
            XB_RUNNING="$XB_RUNNING"
            XB_STOPPED="$XB_STOPPED"
            XB_WAIT_DB="$XB_WAIT_DB"
            XB_WIZARD_TIP="即将进入 XBoard 安装向导，请按以下信息填写"
            XB_DONE="XBoard 部署完成！"
            XB_UNINSTALL_TITLE="卸载 XBoard"
            XB_NOT_FOUND="$XB_NOT_FOUND"
            XB_UNINSTALL_CONFIRM="$XB_UNINSTALL_CONFIRM"
            XB_DELETE_DATA="$XB_DELETE_DATA"
            XB_UNINSTALL_DONE="$XB_UNINSTALL_DONE"
            UI_INSTALL_TITLE="安装 3x-ui"
            UI_RUNNING="$UI_RUNNING"
            UI_DONE="3x-ui 部署完成！"
            UI_SAVE_TIP="$UI_SAVE_TIP"
            UI_UNINSTALL_TITLE="卸载 3x-ui"
            UI_NOT_FOUND="$UI_NOT_FOUND"
            UI_UNINSTALL_CONFIRM="$UI_UNINSTALL_CONFIRM"
            UI_UNINSTALL_DONE="$UI_UNINSTALL_DONE"
            SSH_TITLE="SSH 安全加固"
            SSH_KEY_TITLE="植入 SSH 公钥"
            SSH_KEY_TIP="$SSH_KEY_TIP"
            SSH_KEY_PROMPT="请粘贴你的 SSH 公钥内容（以 ssh-rsa 或 ssh-ed25519 开头）"
            SSH_KEY_ERR="$SSH_KEY_ERR"
            SSH_KEY_DONE="$SSH_KEY_DONE"
            SSH_KEY_WARN="$SSH_KEY_WARN"
            SSH_DISABLE_TITLE="禁用密码登录"
            SSH_NO_KEY="未检测到 SSH 公钥，禁止执行此操作！请先植入 SSH 公钥并验证 Key 登录正常后再禁用密码"
            SSH_DISABLE_TIP1="禁用密码登录后，只能通过 SSH Key 登录"
            SSH_DISABLE_TIP2="请确保已在新窗口验证 Key 登录成功，否则将锁死服务器"
            SSH_DISABLE_CONFIRM="确认已验证 Key 登录正常，现在禁用密码登录？"
            SSH_DISABLE_DONE="$SSH_DISABLE_DONE"
            FW_TITLE="防火墙管理"
            FW_VIEW="$FW_VIEW"
            FW_ADD="$FW_ADD"
            FW_DEL="$FW_DEL"
            FW_STATUS="$FW_STATUS"
            FW_PORT_PROMPT="请输入要放行的端口"
            FW_PROTO_PROMPT="协议 (tcp/udp，默认 tcp)"
            FW_ADD_DONE="端口已放行"
            FW_DEL_DONE="端口规则已删除"
            SYS_TITLE="系统信息与检测"
            SYS_OVERVIEW="$SYS_OVERVIEW"
            SYS_HW="$SYS_HW"
            SYS_STREAM="$SYS_STREAM"
            SYS_ROUTE="$SYS_ROUTE"
            SYS_SPEED="$SYS_SPEED"
            SYS_IP="$SYS_IP"
            DOCKER_TITLE="Docker 容器管理"
            DOCKER_LIST="$DOCKER_LIST"
            DOCKER_RESTART="$DOCKER_RESTART"
            DOCKER_STOP="$DOCKER_STOP"
            DOCKER_LOG="$DOCKER_LOG"
            DOCKER_UPDATE="$DOCKER_UPDATE"
            DOCKER_RESTART_ALL="$DOCKER_RESTART_ALL"
            DOCKER_NAME_PROMPT="请输入容器名称"
            DOCKER_STOP_CONFIRM="确认停止容器"
            DOCKER_LOG_LINES="显示最后多少行日志（默认 50）"
            BACKUP_TITLE="备份与恢复"
            BACKUP_NOW="$BACKUP_NOW"
            BACKUP_RESTORE="$BACKUP_RESTORE"
            BACKUP_LIST="$BACKUP_LIST"
            BACKUP_AUTO="$BACKUP_AUTO"
            BACKUP_DONE="$BACKUP_DONE"
            BACKUP_FILE="备份文件"
            BACKUP_SIZE="备份大小"
            BACKUP_RESTORE_TIP="恢复会覆盖现有数据，请确认后执行"
            BACKUP_RESTORE_CONFIRM="确认恢复备份"
            BACKUP_RESTORE_FILE="请输入要恢复的备份文件名（含路径）"
            BACKUP_NOT_FOUND="$BACKUP_NOT_FOUND"
            BACKUP_NO_BACKUP="$BACKUP_NO_BACKUP"
            BACKUP_STOP_ALL="$BACKUP_STOP_ALL"
            BACKUP_RESTORE_ING="$BACKUP_RESTORE_ING"
            BACKUP_RESTART_ALL="$BACKUP_RESTART_ALL"
            BACKUP_RESTORE_DONE="$BACKUP_RESTORE_DONE"
            BACKUP_AUTO_DAILY="$BACKUP_AUTO_DAILY"
            BACKUP_AUTO_WEEKLY="$BACKUP_AUTO_WEEKLY"
            BACKUP_KEEP_PROMPT="保留最近几份备份（默认 7）"
            BACKUP_AUTO_DONE="自动备份已设置！保留最近"
            BACKUP_AUTO_DONE2="份备份"
            WARP_TITLE="安装 WARP（解决送中）"
            WARP_TIP="$WARP_TIP"
            WARP_CONFIRM="$WARP_CONFIRM"
            NET_TITLE="网络优化"
            NET_IPV4="$NET_IPV4"
            NET_IPV6="$NET_IPV6"
            NET_DIS_IPV6="禁用 IPv6"
            NET_EN_IPV6="$NET_EN_IPV6"
            NET_DNS="$NET_DNS"
            NET_DIS_IPV6_TIP="$NET_DIS_IPV6_TIP"
            NET_DIS_IPV6_CONFIRM="$NET_DIS_IPV6_CONFIRM"
            NET_DNS_CUSTOM="$NET_DNS_CUSTOM"
            NET_DNS1_PROMPT="请输入主 DNS"
            NET_DNS2_PROMPT="请输入副 DNS（可选）"
            CLEAN_TITLE="系统清理"
            CLEAN_BEFORE="清理前可用空间"
            CLEAN_DOCKER="$CLEAN_DOCKER"
            CLEAN_DOCKER_DONE="Docker 清理完成"
            CLEAN_PKG="清理软件包缓存..."
            CLEAN_PKG_DONE="软件包缓存清理完成"
            CLEAN_LOG="$CLEAN_LOG"
            CLEAN_LOG_DONE="$CLEAN_LOG_DONE"
            CLEAN_AFTER="清理后可用空间"
            CLEAN_DONE="$CLEAN_DONE"
            DEPLOY_TITLE="已保存的部署信息"
            DEPLOY_EMPTY="$DEPLOY_EMPTY"
            UPDATE_TITLE="检查脚本更新"
            UPDATE_CURRENT="当前版本"
            UPDATE_CHECKING="$UPDATE_CHECKING"
            UPDATE_FAIL="$UPDATE_FAIL"
            UPDATE_LATEST="当前已是最新版本"
            UPDATE_FOUND="发现新版本"
            UPDATE_CONFIRM="是否更新到"
            UPDATE_DONE="脚本已更新，请重新运行"
            DOMAIN_PROMPT="是否为此服务配置域名？(y/n)"
            DOMAIN_INPUT="请输入域名（如 example.com，不含 www）"
            ACME_TITLE="acme.sh + Cloudflare DNS 申请证书"
            ACME_EMAIL="请输入邮箱地址"
            ACME_CF_TIP="$ACME_CF_TIP"
            ACME_CF_GLOBAL="$ACME_CF_GLOBAL"
            ACME_CF_TOKEN="$ACME_CF_TOKEN"
            ACME_CF_KEY_PROMPT="请输入 Cloudflare Global API Key"
            ACME_CF_EMAIL_PROMPT="请输入 Cloudflare 账号邮箱"
            ACME_CF_TOKEN_PROMPT="请输入 Cloudflare API Token"
            ACME_DOMAIN_PROMPT="请输入要申请证书的主域名（如 example.com）"
            ACME_ISSUING="$ACME_ISSUING"
            ACME_DONE="$ACME_DONE"
            ACME_CERT_PATH="证书路径"
            ACME_KEY_PATH="私钥路径"
            ACME_FAIL="$ACME_FAIL"
            ;;
    esac
}


# ============================================================
# 工具函数
# ============================================================

# 打印标题
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════╗"
    echo "║         $BANNER_TITLE              ║"
    echo "║              v${SCRIPT_VERSION}                       ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 打印分隔线
print_line() {
    echo -e "${BLUE}──────────────────────────────────────────${NC}"
}

# 成功提示
success() { echo -e "${GREEN}✅ $1${NC}"; }

# 错误提示
error() { echo -e "${RED}❌ $1${NC}"; }

# 警告提示
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# 信息提示
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# 安全提示
security_tip() { echo -e "${PURPLE}🔒 安全提示：$1${NC}"; }

# 确认操作
confirm() {
    read -p "$(echo -e ${YELLOW}"$1 $MSG_CONFIRM_YN："${NC})" CONFIRM
    [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]
}

# 生成随机密码
gen_pass() {
    tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c 32
}

# 获取公网 IP
get_public_ip() {
    curl -s4 ifconfig.me 2>/dev/null || curl -s4 ip.sb 2>/dev/null || echo "无法获取"
}

# 保存部署信息
save_info() {
    echo "$1" >> /root/deploy_info.txt
}

# ============================================================
# 系统检测
# ============================================================
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$ID
        OS_VER=$VERSION_ID
        OS_PRETTY=$PRETTY_NAME
    else
        error "无法检测系统版本"
        exit 1
    fi

    case $OS_NAME in
        debian|ubuntu)
            PKG_MANAGER="apt"
            PKG_UPDATE="apt update -y"
            PKG_INSTALL="apt install -y"
            FIREWALL="ufw"
            ;;
        centos|rhel|almalinux|rocky)
            if command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
                PKG_UPDATE="dnf update -y"
                PKG_INSTALL="dnf install -y"
            else
                PKG_MANAGER="yum"
                PKG_UPDATE="yum update -y"
                PKG_INSTALL="yum install -y"
            fi
            FIREWALL="firewalld"
            ;;
        fedora)
            PKG_MANAGER="dnf"
            PKG_UPDATE="dnf update -y"
            PKG_INSTALL="dnf install -y"
            FIREWALL="firewalld"
            ;;
        alpine)
            PKG_MANAGER="apk"
            PKG_UPDATE="apk update"
            PKG_INSTALL="apk add"
            FIREWALL="iptables"
            ;;
        *)
            warning "未经测试的系统：$OS_PRETTY，将尝试继续..."
            PKG_MANAGER="apt"
            PKG_UPDATE="apt update -y"
            PKG_INSTALL="apt install -y"
            FIREWALL="ufw"
            ;;
    esac

    success "检测到系统：$OS_PRETTY"
}

# 检测已安装组件
check_installed() {
    DOCKER_INSTALLED=false
    NGINX_INSTALLED=false
    CERTBOT_INSTALLED=false
    ACME_INSTALLED=false
    UFW_INSTALLED=false
    FAIL2BAN_INSTALLED=false

    command -v docker >/dev/null 2>&1 && DOCKER_INSTALLED=true
    command -v nginx >/dev/null 2>&1 && NGINX_INSTALLED=true
    command -v certbot >/dev/null 2>&1 && CERTBOT_INSTALLED=true
    [ -f ~/.acme.sh/acme.sh ] && ACME_INSTALLED=true
    command -v ufw >/dev/null 2>&1 && UFW_INSTALLED=true
    command -v fail2ban-server >/dev/null 2>&1 && FAIL2BAN_INSTALLED=true
}

# 检查 root 权限
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "请使用 root 权限运行此脚本"
        exit 1
    fi
}

# ============================================================
# 安装基础依赖
# ============================================================

# 仅安装基础系统工具（用于初始化加固）
install_base_only() {
    info "更新系统软件包..."
    $PKG_UPDATE >/dev/null 2>&1

    case $PKG_MANAGER in
        apt)
            $PKG_INSTALL curl wget sudo openssl rsyslog >/dev/null 2>&1
            ;;
        yum|dnf)
            $PKG_INSTALL curl wget sudo openssl rsyslog >/dev/null 2>&1
            ;;
        apk)
            $PKG_INSTALL curl wget openssl >/dev/null 2>&1
            ;;
    esac
    success "基础工具已安装"
}

# 安装部署服务所需依赖（Docker + Nginx + Certbot）
install_deploy_deps() {
    install_base_only

    # Docker
    if [ "$DOCKER_INSTALLED" = false ]; then
        info "安装 Docker..."
        curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
        systemctl enable --now docker >/dev/null 2>&1
        $PKG_INSTALL docker-compose-plugin >/dev/null 2>&1
        DOCKER_INSTALLED=true
        success "Docker 已安装"
    else
        success "Docker 已安装，跳过"
    fi

    # Nginx
    if [ "$NGINX_INSTALLED" = false ]; then
        info "安装 Nginx..."
        $PKG_INSTALL nginx >/dev/null 2>&1
        systemctl enable --now nginx >/dev/null 2>&1
        NGINX_INSTALLED=true
        success "Nginx 已安装"
    else
        success "Nginx 已安装，跳过"
    fi

    # Certbot
    if [ "$CERTBOT_INSTALLED" = false ]; then
        info "安装 Certbot..."
        case $PKG_MANAGER in
            apt)
                $PKG_INSTALL certbot python3-certbot-nginx >/dev/null 2>&1
                ;;
            yum|dnf)
                $PKG_INSTALL certbot python3-certbot-nginx >/dev/null 2>&1
                ;;
        esac
        CERTBOT_INSTALLED=true
        success "Certbot 已安装"
    else
        success "Certbot 已安装，跳过"
    fi
}

# 兼容旧调用（部署函数用）
install_base() {
    install_deploy_deps
}

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
# Nginx 配置函数
# ============================================================
setup_nginx_proxy() {
    local DOMAIN=$1
    local PORT=$2
    local CONF_DIR

    case $PKG_MANAGER in
        apt)
            CONF_DIR="/etc/nginx/sites-available"
            mkdir -p /etc/nginx/sites-enabled
            ;;
        yum|dnf|apk)
            CONF_DIR="/etc/nginx/conf.d"
            ;;
    esac

    cat > $CONF_DIR/$DOMAIN << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
    }
}
EOF

    # Debian/Ubuntu 需要创建软链接
    if [ "$PKG_MANAGER" = "apt" ]; then
        rm -f /etc/nginx/sites-enabled/$DOMAIN
        ln -s $CONF_DIR/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
    fi

    nginx -t >/dev/null 2>&1 && systemctl reload nginx >/dev/null 2>&1
    success "Nginx 反代配置完成"
}

# 申请证书
setup_cert() {
    local DOMAIN=$1
    certbot --nginx -d $DOMAIN -d www.$DOMAIN \
        --non-interactive --agree-tos \
        -m admin@$DOMAIN 2>/dev/null
    if [ $? -eq 0 ]; then
        success "SSL 证书申请成功"
    else
        warning "SSL 证书申请失败，请检查域名解析是否生效"
    fi
}

# 询问域名
ask_domain() {
    local SERVICE=$1
    echo ""
    read -p "$(echo -e ${YELLOW}"$DOMAIN_PROMPT："${NC})" HAS_DOMAIN
    if [ "$HAS_DOMAIN" = "y" ] || [ "$HAS_DOMAIN" = "Y" ]; then
        read -p "$DOMAIN_INPUT：" INPUT_DOMAIN
        echo $INPUT_DOMAIN
    else
        echo ""
    fi
}

# ============================================================
# 1. VPS 初始化加固
# ============================================================
init_vps() {
    print_banner
    echo -e "${BOLD}=== $INIT_TITLE ===${NC}\n"

    install_base_only

    # 时区设置
    echo -e "\n${CYAN}请选择时区：${NC}"
    echo "1. 亚洲/东京 (Asia/Tokyo)"
    echo "2. 亚洲/上海 (Asia/Shanghai)"
    echo "3. UTC"
    echo "4. 美国/纽约 (America/New_York)"
    echo "5. 欧洲/伦敦 (Europe/London)"
    echo "6. 自定义"
    read -p "$INIT_TZ_PROMPT：" TZ_CHOICE
    TZ_CHOICE=${TZ_CHOICE:-1}

    case $TZ_CHOICE in
        1) TIMEZONE="Asia/Tokyo" ;;
        2) TIMEZONE="Asia/Shanghai" ;;
        3) TIMEZONE="UTC" ;;
        4) TIMEZONE="America/New_York" ;;
        5) TIMEZONE="Europe/London" ;;
        6) read -p "$INIT_TZ_CUSTOM：" TIMEZONE ;;
        *) TIMEZONE="Asia/Tokyo" ;;
    esac

    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    success "时区已设置为：$TIMEZONE"

    # BBR 加速
    if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf 2>/dev/null; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1
        success "BBR 加速已开启"
    else
        success "BBR 加速已开启，跳过"
    fi

    # Swap 配置
    if [ ! -f /swapfile ]; then
        # 自动检测 RAM 并推荐 Swap
        RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
        if [ $RAM_MB -lt 1024 ]; then
            RECOMMENDED_SWAP="2G"
        elif [ $RAM_MB -lt 2048 ]; then
            RECOMMENDED_SWAP="2G"
        elif [ $RAM_MB -lt 4096 ]; then
            RECOMMENDED_SWAP="2G"
        else
            RECOMMENDED_SWAP="1G"
        fi

        info "$INIT_RAM_DETECT：${RAM_MB}MB，$INIT_SWAP_REC：${RECOMMENDED_SWAP}"
        read -p "$INIT_SWAP_PROMPT ${RECOMMENDED_SWAP}：" SWAP_SIZE
        SWAP_SIZE=${SWAP_SIZE:-$RECOMMENDED_SWAP}

        fallocate -l $SWAP_SIZE /swapfile
        chmod 600 /swapfile
        mkswap /swapfile >/dev/null 2>&1
        swapon /swapfile
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
        success "$INIT_SWAP_DONE ${SWAP_SIZE}"
    else
        success "Swap 已配置，跳过"
    fi

    # DNS 优化
    echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
    success "DNS 已优化（Google + Cloudflare）"

    # IPv4 优先
    grep -q "^precedence ::ffff:0:0/96  100" /etc/gai.conf 2>/dev/null || \
        echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
    success "IPv4 优先已开启"

    # SSH 端口
    CURRENT_SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -n1)
    CURRENT_SSH_PORT=${CURRENT_SSH_PORT:-22}
    info "$INIT_SSH_CURRENT：$CURRENT_SSH_PORT"
    read -p "$INIT_SSH_PROMPT $CURRENT_SSH_PORT：" SSH_PORT
    SSH_PORT=${SSH_PORT:-$CURRENT_SSH_PORT}

    # 防火墙配置
    case $FIREWALL in
        ufw)
            $PKG_INSTALL ufw >/dev/null 2>&1
            ufw --force reset >/dev/null 2>&1
            ufw default deny incoming >/dev/null 2>&1
            ufw default allow outgoing >/dev/null 2>&1
            fw_allow_port $SSH_PORT tcp
            fw_allow_port 80 tcp
            fw_allow_port 443 tcp
            ufw --force enable >/dev/null 2>&1
            success "UFW 防火墙已配置"
            ;;
        firewalld)
            $PKG_INSTALL firewalld >/dev/null 2>&1
            systemctl enable --now firewalld >/dev/null 2>&1
            fw_allow_port $SSH_PORT tcp
            fw_allow_port 80 tcp
            fw_allow_port 443 tcp
            success "firewalld 防火墙已配置"
            ;;
    esac

    # Fail2Ban
    if [ "$FAIL2BAN_INSTALLED" = false ]; then
        $PKG_INSTALL fail2ban >/dev/null 2>&1
    fi
    touch /var/log/auth.log 2>/dev/null
    cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400
findtime = 600
EOF
    systemctl enable --now fail2ban >/dev/null 2>&1
    systemctl restart fail2ban >/dev/null 2>&1
    success "Fail2Ban 已配置（3次错误封禁24小时）"

    # 修改 SSH 端口
    if [ "$SSH_PORT" != "$CURRENT_SSH_PORT" ]; then
        security_tip "修改 SSH 端口前请确认防火墙已放行新端口 $SSH_PORT"
        if confirm "确认修改 SSH 端口为 $SSH_PORT？"; then
            cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
            sed -i "s/^#\?Port .*/Port $SSH_PORT/g" /etc/ssh/sshd_config
            systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
            success "SSH 端口已改为 $SSH_PORT"
            warning "请开启新窗口用端口 $SSH_PORT 验证能否登录，确认后再关闭当前窗口！"
        fi
    fi

    print_line
    success "VPS 初始化加固完成！"
    echo ""
}


# ============================================================
# 2. WordPress 菜单
# ============================================================
wordpress_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}=== WordPress ===${NC}\n"
        echo "1. 安装 WordPress"
        echo "2. 卸载 WordPress"
        echo "0. 返回主菜单"
        print_line
        read -p "请选择 [0-2]：" WP_CHOICE
        case $WP_CHOICE in
            1) deploy_wordpress ;;
            2) uninstall_wordpress ;;
            0) break ;;
            *) error "无效选项" ;;
        esac
    done
}

# ============================================================
# 2. 部署 WordPress
# ============================================================
deploy_wordpress() {
    print_banner
    echo -e "${BOLD}=== $WP_INSTALL_TITLE ===${NC}\n"

    # 检测是否已安装
    if [ -f /opt/wordpress/docker-compose.yml ]; then
        WP_RUNNING=$(docker compose -f /opt/wordpress/docker-compose.yml ps --status running 2>/dev/null | grep -c "running" || echo "0")
        if [ "$WP_RUNNING" -gt "0" ]; then
            warning "检测到 WordPress 已安装且正在运行"
        else
            warning "检测到 WordPress 已安装但未运行"
        fi
        echo ""
        echo "1. 重新安装（覆盖现有配置，数据保留）"
        echo "2. 返回"
        read -p "请选择 [1-2]：" REINSTALL_CHOICE
        case $REINSTALL_CHOICE in
            1)
                info "停止现有容器..."
                cd /opt/wordpress && docker compose down >/dev/null 2>&1
                ;;
            *)
                info "操作已取消"
                read -p "$MSG_PRESS_ENTER"
                return
                ;;
        esac
    fi

    install_base

    WP_DB_PASS=$(gen_pass)
    WP_ROOT_PASS=$(gen_pass)

    mkdir -p /opt/wordpress
    cat > /opt/wordpress/docker-compose.yml << EOF
services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: $WP_DB_PASS
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
  db:
    image: mariadb:10.11
    restart: always
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: $WP_DB_PASS
      MYSQL_ROOT_PASSWORD: $WP_ROOT_PASS
    volumes:
      - db_data:/var/lib/mysql
volumes:
  wordpress_data:
  db_data:
EOF

    info "启动 WordPress 容器..."
    cd /opt/wordpress && docker compose up -d >/dev/null 2>&1
    success "WordPress 容器已启动"

    DOMAIN=$(ask_domain "WordPress")
    if [ -n "$DOMAIN" ]; then
        setup_nginx_proxy $DOMAIN 8080
        setup_cert $DOMAIN
        ACCESS="https://$DOMAIN"
    else
        SERVER_IP=$(get_public_ip)
        ACCESS="http://$SERVER_IP:8080"
        fw_allow_port 8080 tcp
    fi

    print_line
    save_info "
=== WordPress ===
部署时间：$(date)
访问地址：$ACCESS
数据库用户：wpuser
数据库密码：$WP_DB_PASS
数据库 Root 密码：$WP_ROOT_PASS"

    success "WordPress 部署完成！"
    info "$WP_ACCESS：$ACCESS"
    warning "账号信息已保存到 /root/deploy_info.txt"
    echo ""
}

uninstall_wordpress() {
    print_banner
    echo -e "${BOLD}=== $WP_UNINSTALL_TITLE ===${NC}\n"

    if [ ! -d /opt/wordpress ]; then
        error "未检测到 WordPress 安装"
        read -p "按回车键继续..."
        return
    fi

    security_tip "卸载操作不可逆，请确认已备份重要数据"
    if ! confirm "确认卸载 WordPress？"; then
        info "操作已取消"
        return
    fi

    info "停止并删除容器..."
    cd /opt/wordpress && docker compose down >/dev/null 2>&1
    success "容器已停止"

    if confirm "是否同时删除所有数据（数据库、文章、媒体文件）？"; then
        cd /opt/wordpress && docker compose down -v >/dev/null 2>&1
        rm -rf /opt/wordpress
        success "数据已删除"
    else
        rm -f /opt/wordpress/docker-compose.yml
        success "容器已删除，数据目录保留在 /opt/wordpress"
    fi

    read -p "$WP_DOMAIN_PROMPT：" WP_DOMAIN
    if [ -n "$WP_DOMAIN" ]; then
        rm -f /etc/nginx/sites-enabled/$WP_DOMAIN
        rm -f /etc/nginx/sites-available/$WP_DOMAIN
        rm -f /etc/nginx/conf.d/$WP_DOMAIN
        nginx -t >/dev/null 2>&1 && systemctl reload nginx >/dev/null 2>&1
        success "Nginx 配置已删除"
    fi

    success "WordPress 已卸载完成"
    echo ""
    read -p "按回车键继续..."
}



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

    x-ui uninstall 2>/dev/null || bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) uninstall

    success "3x-ui 已卸载完成"
    echo ""
    read -p "按回车键继续..."
}


# ============================================================
# 5. 为面板申请域名证书（acme.sh + CF DNS）
# ============================================================
setup_acme_cert() {
    print_banner
    echo -e "${BOLD}=== $ACME_TITLE ===${NC}\n"

    # 安装 acme.sh
    if [ "$ACME_INSTALLED" = false ]; then
        read -p "$ACME_EMAIL：" ACME_EMAIL_INPUT; ACME_EMAIL=$ACME_EMAIL_INPUT
        curl https://get.acme.sh | sh -s email=$ACME_EMAIL >/dev/null 2>&1
        source ~/.bashrc
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt >/dev/null 2>&1
        ACME_INSTALLED=true
        success "acme.sh 已安装"
    else
        success "acme.sh 已安装，跳过"
    fi

    # CF API Key
    security_tip "建议使用 CF API Token（仅 DNS 编辑权限）而非 Global API Key，权限更小更安全"
    echo ""
    echo "1. 使用 Global API Key（权限较大）"
    echo "2. 使用 API Token（推荐，权限更小）"
    read -p "请选择 [1-2，默认 2]：" CF_AUTH_TYPE
    CF_AUTH_TYPE=${CF_AUTH_TYPE:-2}

    if [ "$CF_AUTH_TYPE" = "1" ]; then
        read -p "$ACME_CF_KEY_PROMPT：" CF_KEY_INPUT
        read -p "$ACME_CF_EMAIL_PROMPT：" CF_EMAIL_INPUT
        export CF_Key="$CF_KEY_INPUT"
        export CF_Email="$CF_EMAIL_INPUT"
    else
        read -p "$ACME_CF_TOKEN_PROMPT：" CF_TOKEN_INPUT
        export CF_Token="$CF_TOKEN_INPUT"
    fi

    read -p "$ACME_DOMAIN_PROMPT：" CERT_DOMAIN

    info "申请通配符证书中..."
    ~/.acme.sh/acme.sh --issue --dns dns_cf \
        -d $CERT_DOMAIN \
        -d *.$CERT_DOMAIN \
        --force 2>/dev/null

    if [ $? -eq 0 ]; then
        mkdir -p /root/cert/$CERT_DOMAIN
        ~/.acme.sh/acme.sh --install-cert -d $CERT_DOMAIN \
            --key-file /root/cert/$CERT_DOMAIN/private.key \
            --fullchain-file /root/cert/$CERT_DOMAIN/cert.crt \
            --reloadcmd "x-ui restart 2>/dev/null; nginx -s reload 2>/dev/null; true"
        chmod -R 755 /root/cert

        save_info "
=== acme.sh 证书 ===
域名：$CERT_DOMAIN
证书路径：/root/cert/$CERT_DOMAIN/cert.crt
私钥路径：/root/cert/$CERT_DOMAIN/private.key
申请时间：$(date)"

        print_line
        success "证书申请完成！"
        info "$ACME_CERT_PATH：/root/cert/$CERT_DOMAIN/cert.crt"
        info "$ACME_KEY_PATH：/root/cert/$CERT_DOMAIN/private.key"
    else
        error "证书申请失败，请检查域名解析和 API Key 是否正确"
    fi
    echo ""
}

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
    bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)
}

check_route() {
    echo -e "\n${BOLD}=== 路由回程测试 ===${NC}\n"

    # 安装 nexttrace
    if ! command -v nexttrace >/dev/null 2>&1; then
        info "安装 nexttrace..."
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

    speedtest 2>/dev/null || curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}

check_ip_quality() {
    echo -e "\n${BOLD}=== IP 质量检测 ===${NC}\n"
    SERVER_IP=$(get_public_ip)
    info "检测 IP：$SERVER_IP"
    echo ""
    curl -s https://ip.check.place 2>/dev/null || \
    curl -s "https://ipinfo.io/$SERVER_IP/json" 2>/dev/null | python3 -m json.tool 2>/dev/null || \
        info "请访问 https://ip.check.place 手动检测"
}

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
#!/bin/bash
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

# ============================================================
# 主菜单
# ============================================================
main_menu() {
    while true; do
        print_banner
        echo -e " ${GREEN}一、核心部署${NC}"
        echo -e " ${GREEN}1.${NC}  $MENU_1"
        echo -e " ${GREEN}2.${NC}  $MENU_2"
        echo -e " ${GREEN}3.${NC}  $MENU_3"
        echo -e " ${GREEN}4.${NC}  $MENU_4"
        echo -e " ${GREEN}5.${NC}  为面板申请域名证书 (acme.sh + CF DNS)"
        echo ""
        echo -e " ${CYAN}二、安全管理${NC}"
        echo -e " ${CYAN}6.${NC}  $MENU_6"
        echo -e " ${CYAN}7.${NC}  防火墙管理"
        echo ""
        echo -e " ${YELLOW}三、系统信息与检测${NC}"
        echo -e " ${YELLOW}8.${NC}  系统信息与检测"
        echo ""
        echo -e " ${PURPLE}四、Docker 管理${NC}"
        echo -e " ${PURPLE}9.${NC}  $MENU_9"
        echo ""
        echo -e " ${BLUE}$CAT_BACKUP${NC}"
        echo -e " ${BLUE}10.${NC} $MENU_10"
        echo ""
        echo -e " ${GREEN}六、网络工具${NC}"
        echo -e " ${GREEN}11.${NC} $MENU_11"
        echo -e " ${GREEN}12.${NC} $MENU_12"
        echo ""
        echo -e " ${CYAN}七、系统维护${NC}"
        echo -e " ${CYAN}13.${NC} $MENU_13"
        echo -e " ${CYAN}14.${NC} $MENU_14"
        echo -e " ${CYAN}15.${NC} $MENU_15"
        echo ""
        echo -e " ${RED}0.${NC}  退出"
        print_line
        echo -e "                    ${PURPLE}by noob ra2${NC}"
        print_line
        read -p "$MENU_PROMPT：" MAIN_CHOICE

        case $MAIN_CHOICE in
            1)  init_vps ;;
            2)  wordpress_menu ;;
            3)  xboard_menu ;;
            4)  threeui_menu ;;
            5)  setup_acme_cert ;;
            6)  ssh_security_menu ;;
            7)  firewall_menu ;;
            8)  system_info_menu ;;
            9)  docker_menu ;;
            10) backup_menu ;;
            11) install_warp ;;
            12) network_menu ;;
            13) system_clean ;;
            14) show_deploy_info ;;
            15) check_update ;;
            0)
                echo -e "\n${CYAN}╔══════════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║   感谢使用 noob ra2 VPS 工具箱           ║${NC}"
                echo -e "${CYAN}║   愿你的服务器永远稳如磐石 🚀            ║${NC}"
                echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}\n"
                exit 0
                ;;
            *)
                error "无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# 入口
# ============================================================
check_root
select_language
detect_os
check_installed
main_menu
