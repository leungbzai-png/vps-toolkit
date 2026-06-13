# shellcheck shell=bash


# ============================================================
# 主菜单
# ============================================================
main_menu() {
    while true; do
        print_banner
        echo -e " ${GREEN}$CAT_DEPLOY${NC}"
        echo -e " ${GREEN}1.${NC}  $MENU_1"
        echo -e " ${GREEN}2.${NC}  $MENU_2"
        echo -e " ${GREEN}3.${NC}  $MENU_3"
        echo -e " ${GREEN}4.${NC}  $MENU_4"
        echo -e " ${GREEN}5.${NC}  $MENU_5"
        echo ""
        echo -e " ${CYAN}$CAT_SECURITY${NC}"
        echo -e " ${CYAN}6.${NC}  $MENU_6"
        echo -e " ${CYAN}7.${NC}  $MENU_7"
        echo ""
        echo -e " ${YELLOW}$CAT_SYSINFO${NC}"
        echo -e " ${YELLOW}8.${NC}  $MENU_8"
        echo ""
        echo -e " ${PURPLE}$CAT_DOCKER${NC}"
        echo -e " ${PURPLE}9.${NC}  $MENU_9"
        echo ""
        echo -e " ${BLUE}$CAT_BACKUP${NC}"
        echo -e " ${BLUE}10.${NC} $MENU_10"
        echo ""
        echo -e " ${GREEN}$CAT_NETWORK${NC}"
        echo -e " ${GREEN}11.${NC} $MENU_11"
        echo -e " ${GREEN}12.${NC} $MENU_12"
        echo ""
        echo -e " ${CYAN}$CAT_MAINTAIN${NC}"
        echo -e " ${CYAN}13.${NC} $MENU_13"
        echo -e " ${CYAN}14.${NC} $MENU_14"
        echo -e " ${CYAN}15.${NC} $MENU_15"
        echo ""
        echo -e " ${RED}0.${NC}  $MENU_0"
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
