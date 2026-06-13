# vps-toolkit

> noob ra2 VPS 工具箱 — 面向个人 VPS 用户的 Linux 运维工具箱

一个透明、可读、可控的单文件（构建产物）Bash 工具箱，用于 Debian / Ubuntu 等 VPS 的初始化加固、常用服务部署、安全管理、Docker 管理、备份恢复、网络检测与系统维护。

当前版本：**v0.2.0（Project Structure Edition）**
版本路线见 [ROADMAP.md](ROADMAP.md)。**注意：当前尚未发布正式 v1.0.0**，多系统测试稳定后才会发布。

---

## 功能列表

- **多语言界面**：简体中文 / 繁體中文 / English / 日本語
  - ⚠️ 目前 i18n 仅部分接入：菜单与各功能标题已翻译，但许多功能内部的提示仍为简体中文。完整 i18n 列入后续版本。
- **VPS 初始化与加固**：系统检测、root 检测、基础依赖、时区、BBR、Swap、DNS 优化、IPv4 优先、SSH 端口修改、UFW/firewalld、Fail2Ban
- **服务部署**：WordPress、XBoard、3x-ui、Nginx 反代、acme.sh + Cloudflare DNS 证书
- **安全管理**：SSH 公钥植入、禁用密码登录、防火墙管理
- **系统信息与检测**：系统概览、硬件信息、流媒体解锁检测、回程路由、speedtest、IP 质量检测
- **Docker 管理**：查看 / 重启 / 停止容器、查看日志、更新镜像、一键重启所有服务
- **备份与恢复**：手动备份、恢复、备份列表、自动定时备份
- **网络与维护**：WARP、IPv4/IPv6 优先、禁用/启用 IPv6、DNS 切换、系统清理、查看部署信息、检查脚本更新

完整菜单说明见 [docs/COMMANDS.md](docs/COMMANDS.md)。

## 支持系统

- ✅ 主要支持并测试方向：**Debian / Ubuntu**
- ⚠️ 部分兼容（未充分测试）：CentOS / RHEL / AlmaLinux / Rocky / Fedora（firewalld）、Alpine（iptables）
- 需要 **root** 权限运行

## 安装与使用

需要 root。一键运行（与历史用法保持一致）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/leungbzai-png/vps-toolkit/main/setup.sh)
```

或下载后运行：

```bash
curl -fsSL -o setup.sh https://raw.githubusercontent.com/leungbzai-png/vps-toolkit/main/setup.sh
chmod +x setup.sh
./setup.sh
```

或从源码运行（开发者）：

```bash
git clone https://github.com/leungbzai-png/vps-toolkit.git
cd vps-toolkit
bash build.sh   # 由 lib/ + modules/ 生成 setup.sh
bash setup.sh
```

更多见 [docs/USAGE.md](docs/USAGE.md)。

## 项目结构

`setup.sh` 是**由 `build.sh` 自动生成的单文件构建产物**（保证一键 `curl | bash` 与脚本内自更新可用）。真正的源码在 `lib/` 与 `modules/`：

```
setup.sh            # 生成的单文件产物（请勿手改）
build.sh            # 将 lib/ + modules/ 拼接为 setup.sh
lib/                # common.sh / detect.sh / i18n.sh
modules/            # 各功能模块
docs/               # USAGE / COMMANDS / RELEASE / AI_HANDOFF
tests/shellcheck.sh # 本地静态检查
```

修改流程：编辑 `lib/*.sh` 或 `modules/*.sh` → 运行 `bash build.sh` → 提交。

## 安全说明

本工具会**修改系统配置**（SSH、防火墙、DNS、网络、删除数据等），并会执行若干**第三方安装脚本**。**执行前务必先做快照 / 备份。** 详见 [SECURITY.md](SECURITY.md)。

### 第三方脚本声明

本项目会调用以下第三方脚本（均直接执行，未做来源/完整性校验，列入 v0.3 安全加固）：

- Docker 官方安装脚本 `get.docker.com`
- acme.sh 安装脚本 `get.acme.sh`
- 3x-ui 安装脚本（mhsanaei/3x-ui）
- WARP 安装脚本（`git.io/warp.sh`）
- 流媒体解锁 / 回程路由 / IP 质量等检测脚本

## 免责声明

本项目按「现状（AS IS）」提供，不对任何数据丢失、服务器锁死、配置损坏或其他后果负责。请在**理解每一步操作**并**做好备份**的前提下使用，风险自负。详见 [LICENSE](LICENSE)。

## Roadmap

阶段规划见 [ROADMAP.md](ROADMAP.md)；变更历史见 [CHANGELOG.md](CHANGELOG.md)；参与贡献见 [CONTRIBUTING.md](CONTRIBUTING.md)。
