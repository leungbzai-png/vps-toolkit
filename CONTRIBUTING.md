# 贡献指南 / Contributing

感谢参与 vps-toolkit。本项目的核心原则：**透明、可读、可控、安全、易长期维护**。

## 重要：不要手改 setup.sh

`setup.sh` 是 `build.sh` 的**生成产物**。请编辑源码后重新构建：

```bash
# 1. 编辑源码
#    lib/common.sh   颜色 / 通用函数 / 版本
#    lib/detect.sh   系统与组件检测
#    lib/i18n.sh     语言包
#    modules/*.sh    各功能模块

# 2. 重新生成 setup.sh
bash build.sh

# 3. 自检
bash -n setup.sh
bash tests/shellcheck.sh

# 4. 提交（同时提交源码与生成的 setup.sh）
```

## 代码约定

- 目标 Shell：`bash`（脚本头部 `#!/bin/bash`）。源码片段顶部带 `# shellcheck shell=bash`。
- 保持既有**函数名不变**，避免连锁破坏。新功能尽量放进 `modules/`，不要让单个文件无限膨胀。
- 行尾使用 **LF**。
- 面向中文用户，注释与提示以简体中文为主；改动语言包时四种语言（zh_cn / zh_tw / en / ja）保持键一致，**不要使用自引用赋值**（如 `X="$X"`）。

## 高风险改动

涉及 SSH、防火墙、DNS、删除数据、第三方脚本执行的改动，必须：

1. 保留或增加二次确认 / 醒目提示；
2. 在 `SECURITY.md` 更新风险说明；
3. 不在未充分测试时改变既有行为（参见各处 `# TODO[v0.3-安全加固]`）。

## 提交信息

使用清晰的前缀，例如：

- `feat:` 新功能
- `fix:` 修复
- `refactor:` 重构（不改行为）
- `docs:` 文档
- `chore:` 杂项 / 工程化

## 测试

无 Linux 环境时，可用 WSL 或 Git Bash 运行：

```bash
bash -n setup.sh
bash -n lib/*.sh
bash -n modules/*.sh
bash tests/shellcheck.sh   # 需安装 shellcheck；未安装会跳过
```

CI（GitHub Actions）会在每次 push / PR 上自动运行 ShellCheck。
