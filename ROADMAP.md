# Roadmap

版本策略：虽然脚本曾内部标注 `1.0.0`，但仓库工程化尚未成熟，**暂不发布正式 v1.0.0**。

## v0.2.0 — Project Structure Edition ✅（当前）

- [x] 单文件拆分为 `lib/` + `modules/`，保留 `setup.sh` 作为可运行入口（构建产物）。
- [x] 新增 `build.sh` 拼接构建，保留 `curl | bash` 一键安装与脚本自更新。
- [x] 修复语言包自引用与简繁混用 Bug。
- [x] 补齐文档（README / CHANGELOG / SECURITY / CONTRIBUTING / docs/*）。
- [x] 工程化：LICENSE、.gitignore、tests/shellcheck.sh、GitHub Actions。
- [x] 高风险操作加 `# TODO[v0.3-安全加固]` 标记与 SECURITY 说明。
- [ ] （遗留）ShellCheck 告警清理：本轮不追零，详见下方「已知问题」。

## v0.3.0 — Safety Hardening Edition（下一轮重点）

围绕各模块中的 `# TODO[v0.3-安全加固]` 标记：

- [ ] SSH：改端口 / 禁用密码前 `sshd -t` 校验配置，提供自动回滚窗口，避免锁死。
- [ ] 防火墙：避免无条件 `ufw --force reset`，改为增量配置或显式确认。
- [ ] DNS：覆盖 `/etc/resolv.conf` 前备份并检测 `systemd-resolved` / `NetworkManager` 托管。
- [ ] 删除数据：`rm -rf /opt/*` 与 `docker compose down -v` 前强制本地备份与二次确认。
- [ ] 第三方脚本：固定版本 / 校验来源（pin commit、校验 checksum 或改用发行版仓库）。
- [ ] Cloudflare 凭据：避免回显与落盘日志，引导最小权限 Token。
- [ ] 输入与路径变量统一加引号（消化 ShellCheck SC2086 等）。

## v0.4.0 — Deployment Stability Edition

- [ ] 重点测试 WordPress / XBoard / 3x-ui / acme.sh 在主流系统上的部署稳定性。
- [ ] 完成 i18n 接入：将功能内部硬编码的中文提示改为语言变量。
- [ ] 端口/域名/重装流程的边界与幂等性测试。

## v1.0.0 — Stable

- [ ] 多系统（Debian/Ubuntu 多版本，可选 RHEL 系）实测稳定。
- [ ] ShellCheck 关键告警清零。
- [ ] 安全加固与部署稳定性两轮验收通过后发布。

---

## 已知问题 / 技术债

- **i18n 部分接入**：选择 English / 日本語 时，菜单与标题已翻译，但多数功能内部提示仍为简体中文。
- **ShellCheck 残留告警**：大量未加引号变量（SC2086）、`cd` 未接 `|| exit`（SC2164）、`$(...)` 返回值掩盖（SC2155）、`cat | grep`（SC2002）等。本轮以「跑起来 + 记录」为目标，不为清零而改逻辑。运行 `bash tests/shellcheck.sh` 查看当前数量。
- **行尾**：源码与构建产物统一为 LF。
