# 安全说明 / Security

本工具箱会**直接修改系统关键配置**并**执行第三方脚本**。请务必阅读本文件后再使用。

## 0. 执行前请先快照 / 备份

- 在云服务商控制台对 VPS 做**快照**，或至少备份 `/etc/ssh/sshd_config`、`/etc/resolv.conf`、防火墙规则、`/opt` 数据目录。
- 修改 SSH 后，**保留当前已登录的窗口不要关闭**，另开新窗口验证可登录后再关闭旧窗口。

## 1. 高风险操作清单

下列操作在代码中均标有 `# TODO[v0.3-安全加固]`，本轮仅加注释/提示，行为未变；加固列入 v0.3。

| 操作 | 位置 | 风险 |
|---|---|---|
| 修改 `sshd_config`（改端口 / 禁用密码） | `modules/init.sh`、`modules/security.sh` | 配置错误或公钥无效会**锁死服务器** |
| `ufw --force reset` | `modules/init.sh` | **清空所有已有防火墙规则** |
| 覆盖 `/etc/resolv.conf` | `modules/init.sh`、`modules/network.sh` | 丢失原 DNS 配置；可能被 systemd-resolved/NetworkManager 还原 |
| `rm -rf /opt/wordpress` `/opt/xboard` | `modules/deploy_wordpress.sh`、`modules/deploy_xboard.sh` | **不可逆删除数据** |
| `docker compose down -v` | 同上 | **删除数据卷（数据库等）** |
| 禁用 IPv6 | `modules/network.sh` | 影响依赖 IPv6 的服务 |
| Swap / fstab 写入 | `modules/init.sh` | 修改 `/etc/fstab` |

## 2. 第三方脚本风险

以下脚本通过 `curl | sh` 或 `bash <(curl ...)` **直接执行，未校验来源与完整性**。它们由各自上游维护，内容可能随时变化：

- Docker：`https://get.docker.com`
- acme.sh：`https://get.acme.sh`
- 3x-ui：`https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh`
- WARP：`git.io/warp.sh`（短链，存在失效/劫持风险）
- 流媒体解锁 / 回程路由（nexttrace）/ speedtest / IP 质量 等检测脚本

**建议**：在重要生产环境中，先手动审阅这些脚本，或改用固定版本 / 发行版官方仓库安装。

## 3. Cloudflare Token 安全建议

- **优先使用 API Token**（仅授予 `Zone:DNS:Edit` 权限），而非 Global API Key。
- Token 输入时会进入进程环境变量并可能被 acme.sh 写入其配置目录（`~/.acme.sh`）。请勿在共享/不可信主机上输入。
- 用完后可在 Cloudflare 后台吊销该 Token。

## 4. 不要提交机密信息

仓库 `.gitignore` 已忽略 `.env`、`secrets.env`、`*.key`、`*.pem`、`deploy_info.txt`、`backup*/` 等。请**不要**把以下内容提交进 Git 或贴进 Issue / PR：

- SSH 私钥、证书私钥
- Cloudflare Token / Global API Key
- 服务器真实 IP、域名等私密信息
- `/root/deploy_info.txt`（脚本会把数据库密码等写入此文件）

## 5. 报告安全问题

如发现安全问题，请通过仓库 Issue 标注（不要在公开 Issue 中粘贴真实凭据），或私下联系维护者。
