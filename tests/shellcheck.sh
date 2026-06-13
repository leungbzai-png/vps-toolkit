#!/usr/bin/env bash
# ============================================================
# tests/shellcheck.sh
# 对 setup.sh、lib/*.sh、modules/*.sh 运行 bash 语法检查与 ShellCheck。
#
# - bash -n：始终运行（语法门禁）。
# - shellcheck：未安装则跳过（不视为失败），本地无 shellcheck 也能用。
#
# 注意：本项目当前**不追求 ShellCheck 告警清零**（见 ROADMAP「已知问题」），
# 本脚本默认即使有告警也返回 0，仅打印汇总；要让告警变为失败请加 --strict。
# ============================================================
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

STRICT=0
[ "${1:-}" = "--strict" ] && STRICT=1

FILES=(setup.sh)
for f in lib/*.sh modules/*.sh build.sh; do
  [ -f "$f" ] && FILES+=("$f")
done

echo "==> bash -n 语法检查"
syntax_fail=0
for f in "${FILES[@]}"; do
  if bash -n "$f" 2>/dev/null; then
    echo "  ok   $f"
  else
    echo "  FAIL $f"
    bash -n "$f" || true
    syntax_fail=1
  fi
done

if [ "$syntax_fail" -ne 0 ]; then
  echo "语法检查失败。"
  exit 1
fi

echo ""
echo "==> ShellCheck"
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "  未检测到 shellcheck，跳过（可访问 https://www.shellcheck.net 或安装后再跑）。"
  echo "  Debian/Ubuntu: sudo apt install shellcheck"
  exit 0
fi

# external-sources 允许跟随 source；fragment 用指令声明为 bash。
sc_status=0
shellcheck --severity=warning "${FILES[@]}" || sc_status=$?

echo ""
if [ "$sc_status" -eq 0 ]; then
  echo "ShellCheck 无 warning 级以上问题。"
else
  echo "ShellCheck 报告了问题（退出码 $sc_status）。"
  if [ "$STRICT" -eq 1 ]; then
    echo "（--strict）以失败退出。"
    exit "$sc_status"
  fi
  echo "本轮策略：不追求清零，已知残留记录在 ROADMAP.md。"
fi
exit 0
