# Changelog

本项目变更记录。遵循 [Keep a Changelog](https://keepachangelog.com/) 风格与 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

- 计划：见 [ROADMAP.md](ROADMAP.md)。
- 下一步重点（v0.3.0 Safety Hardening）：SSH / 防火墙 / DNS / 删除数据 / 第三方脚本的安全加固（见各模块 `# TODO[v0.3-安全加固]` 标记）。

## [0.2.0] - 2026-06-13 — Project Structure Edition

本轮目标：**保功能、拆结构、补文档、加基础工程化**，不重写核心逻辑，不改变功能行为。

### Added
- 项目化结构：`lib/`（common / detect / i18n）+ `modules/`（各功能模块）作为开发源码。
- `build.sh`：将 `lib/` + `modules/` 拼接生成单文件 `setup.sh`（保留 `curl | bash` 一键安装与脚本自更新）。
- 文档：`README.md`、`CHANGELOG.md`、`ROADMAP.md`、`SECURITY.md`、`CONTRIBUTING.md`、`docs/{USAGE,COMMANDS,RELEASE,AI_HANDOFF}.md`。
- 工程化：`LICENSE`(MIT)、`.gitignore`、`tests/shellcheck.sh`、GitHub Actions `shellcheck.yml`。
- 高风险操作处新增 `# TODO[v0.3-安全加固]` 标记（第三方脚本、`ufw --force reset`、覆盖 `/etc/resolv.conf`、改 `sshd_config`、`rm -rf /opt/*`、`docker compose down -v`、CF 凭据）。

### Fixed
- **i18n 严重 Bug**：默认简体中文语言包中 `MENU_10`–`MENU_15`、`CAT_BACKUP` 等变量自引用导致主菜单整行空白；已全部修正。
- 简体中文语言包混入的繁体字（`系統`/`網路`/`憑證`/`防火牆` 等）已改为简体。
- 繁体中文语言包中 `MSG_CANCEL`、`WP_DONE`、`XB_DONE`、`UI_DONE` 等自引用空值已修正。
- 行尾从 CRLF 规范化为 LF（避免在部分 Linux shell 下执行异常）。

### Changed
- 脚本内部版本号由 `1.0.0` 调整为 `0.2.0`（工程化尚未成熟，暂不发布正式 v1.0.0）。

### Notes
- **未改变任何功能行为**：拆分后函数集合与函数体与原始单文件逐项核对一致（60 个函数）。
- i18n 仍为部分接入，完整多语言列入后续版本。

## [0.1.0] - Legacy Single-file Edition

- 初始的单文件 `setup.sh`（脚本内标注版本 1.0.0），包含全部既有功能。
- 作为历史基线保留，对应本仓库 v0.2.0 之前的提交。

[Unreleased]: https://github.com/leungbzai-png/vps-toolkit/compare/main...HEAD
