# 菜单功能说明 / Commands

主菜单按分类组织，编号 `0-15`。以下为各项说明及对应源码模块。

## 一、核心部署

| 编号 | 功能 | 说明 | 模块 |
|---|---|---|---|
| 1 | VPS 初始化加固 | 基础依赖、时区、BBR、Swap、DNS 优化、IPv4 优先、SSH 端口、UFW/firewalld、Fail2Ban | `modules/init.sh` |
| 2 | 部署 WordPress | Docker Compose 部署 WordPress + MariaDB，可选 Nginx 反代 + 证书 | `modules/deploy_wordpress.sh` |
| 3 | 部署 XBoard | Docker Compose 部署 XBoard + MariaDB + Redis，含安装向导 | `modules/deploy_xboard.sh` |
| 4 | 部署 3x-ui | 调用 3x-ui 官方安装脚本 | `modules/deploy_3xui.sh` |
| 5 | 申请域名证书 | acme.sh + Cloudflare DNS 申请通配符证书 | `modules/cert.sh` |

## 二、安全管理

| 编号 | 功能 | 说明 | 模块 |
|---|---|---|---|
| 6 | SSH 安全加固 | 植入 SSH 公钥、禁用密码登录 | `modules/security.sh` |
| 7 | 防火墙管理 | 查看规则、放行/删除端口、查看状态（兼容 UFW / firewalld） | `modules/firewall.sh` |

## 三、系统信息与检测

| 编号 | 功能 | 说明 | 模块 |
|---|---|---|---|
| 8 | 系统信息与检测 | 系统概览、硬件信息、流媒体解锁、回程路由、网速、IP 质量 | `modules/system_info.sh` |

## 四、Docker 管理

| 编号 | 功能 | 说明 | 模块 |
|---|---|---|---|
| 9 | Docker 容器管理 | 查看 / 重启 / 停止容器、查看日志、更新镜像、一键重启所有服务 | `modules/docker.sh` |

## 五、备份与恢复

| 编号 | 功能 | 说明 | 模块 |
|---|---|---|---|
| 10 | 备份与恢复 | 立即备份 `/opt`、恢复备份、查看备份列表、设置自动定时备份 | `modules/backup.sh` |

## 六、网络工具

| 编号 | 功能 | 说明 | 模块 |
|---|---|---|---|
| 11 | 安装 WARP | 调用 WARP 安装脚本（IPv6 / IPv4 / 双栈） | `modules/network.sh` |
| 12 | 网络优化 | IPv4/IPv6 优先、禁用/启用 IPv6、切换 DNS | `modules/network.sh` |

## 七、系统维护

| 编号 | 功能 | 说明 | 模块 |
|---|---|---|---|
| 13 | 系统清理 | 清理 Docker 无用镜像、包缓存、系统日志 | `modules/cleanup.sh` |
| 14 | 查看部署信息 | 查看 `/root/deploy_info.txt` | `modules/update.sh` |
| 15 | 检查脚本更新 | 比对远程版本并可自更新 | `modules/update.sh` |
| 0 | 退出 | — | `modules/menu.sh` |

> 标有 `# TODO[v0.3-安全加固]` 的操作存在风险，详见 [../SECURITY.md](../SECURITY.md)。
