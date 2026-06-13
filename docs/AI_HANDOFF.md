# AI 接手说明 / AI Handoff

写给后续接手本项目的 AI（或开发者）。请先读完再动手。

## 1. 项目定位

面向**个人 VPS 用户**的 Linux 运维工具箱，主要服务 **Debian/Ubuntu**。目标：透明、可读、可控、安全、易长期维护。这是一个**已有大量功能的成熟项目，不是空项目或 demo**。

## 2. 最重要的原则

- **不要从零重写。不要删功能。不要大改核心逻辑。**
- 优先「保功能」，其次才是优化。改动前先确认不会破坏既有行为。
- 先模块化与文档化，再做安全加固——顺序不要颠倒。

## 3. 当前结构（v0.2.0）

```
setup.sh            # ⚠️ 生成产物，请勿手改
build.sh            # 拼接 lib/ + modules/ -> setup.sh
lib/
  common.sh         # 颜色、success/error/warning/info、confirm、gen_pass、
                    # get_public_ip、save_info、print_banner/line、VERSION
  detect.sh         # detect_os、check_installed、check_root、包管理器变量
  i18n.sh           # select_language、load_language（四语言包）
modules/
  init.sh           # install_base*、init_vps
  firewall.sh       # fw_* helpers、firewall_menu
  cert.sh           # setup_nginx_proxy、setup_cert、ask_domain、setup_acme_cert
  deploy_wordpress.sh / deploy_xboard.sh / deploy_3xui.sh
  security.sh       # ssh_*（公钥、禁用密码）
  system_info.sh    # 系统概览/硬件/流媒体/路由/网速/IP
  docker.sh         # docker_menu
  backup.sh         # 备份/恢复/列表/自动备份
  network.sh        # install_warp、network_menu
  cleanup.sh        # system_clean
  update.sh         # show_deploy_info、check_update
  menu.sh           # main_menu（主菜单 + 调度）
docs/ tests/ .github/workflows/
```

### 构建模型（务必理解）

- 用户通过 `bash <(curl .../main/setup.sh)` 一键安装，并用菜单 15 自更新——两者都要求**远程 `setup.sh` 是自包含单文件**。
- 因此采用：源码在 `lib/`+`modules/`，`build.sh` 拼接成单文件 `setup.sh` 并提交。**改源码后必须 `bash build.sh` 再提交。**
- `build.sh` 按列表拼接、去掉片段的 shebang 与 `# shellcheck shell=bash` 指令、规范化为 LF，并在末尾追加入口序列：`check_root → select_language → detect_os → check_installed → main_menu`。
- bash 中**函数定义顺序无关**（入口在所有函数定义之后才执行），所以拼接顺序可读性优先即可。

## 4. 高风险功能（已标 `# TODO[v0.3-安全加固]`，本轮未重构）

`grep -rn 'TODO\[v0.3' lib modules` 可列出全部。包括：

- 第三方脚本直接执行：Docker `get.docker.com`、acme.sh、3x-ui、WARP `git.io/warp.sh`、流媒体/路由/IP/speedtest 检测脚本。
- `ufw --force reset`（清空规则）。
- 覆盖 `/etc/resolv.conf`。
- 改 `sshd_config`（改端口 / 禁用密码，**锁死风险**）。
- 删除数据：`rm -rf /opt/{wordpress,xboard}` + `docker compose down -v`。
- Cloudflare Token / Global API Key 输入。

加固方向见 [../ROADMAP.md](../ROADMAP.md) v0.3.0 与 [../SECURITY.md](../SECURITY.md)。

## 5. 已知限制

- **i18n 仅部分接入**：菜单与标题用语言变量；许多功能内部提示仍硬编码简体中文。完整 i18n 列入后续版本。
- **ShellCheck 残留告警**：大量 SC2086（未加引号）等。本轮不追零，记录在 ROADMAP；加固时一并处理，不要为清告警而改逻辑。

## 6. 工作流速记

```bash
# 改源码 -> 构建 -> 自检
vim modules/xxx.sh
bash build.sh
bash -n setup.sh && bash tests/shellcheck.sh
# 验证未改坏行为：函数集合应与改前一致
grep -oE '^[a-zA-Z_]+\(\)' setup.sh | sort | uniq | wc -l   # 期望 60（除非有意增删）
```

## 7. 版本

`0.x` 阶段，**暂不发 v1.0.0**。当前 v0.2.0。
