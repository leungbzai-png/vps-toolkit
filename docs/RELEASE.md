# 发布流程 / Release

`setup.sh` 是构建产物，发布前务必由源码重新生成，保证仓库中的 `setup.sh` 与 `lib/` + `modules/` 一致。

## 1. 准备

```bash
# 编辑 lib/*.sh 或 modules/*.sh 后
bash build.sh
```

## 2. 自检

```bash
bash -n setup.sh
bash -n lib/*.sh
bash -n modules/*.sh
bash tests/shellcheck.sh
git diff --stat
```

确认 `setup.sh` 与源码一致（CI 也会校验，见下方「构建一致性」）。

## 3. 更新版本与变更记录

- 修改 `lib/common.sh` 中的 `VERSION` 与 `SCRIPT_VERSION`，以及头部注释的版本号。
- 重新 `bash build.sh`（让 `setup.sh` 内的版本同步）。
- 更新 `CHANGELOG.md`（把 Unreleased 内容归入新版本）。

> 自更新功能依赖 `setup.sh` 中 `VERSION="x.y.z"` 这一行（`check_update` 通过 grep 远程文件的 `^VERSION=` 比对版本），构建产物必须包含该行。

## 4. 提交与打标签

```bash
git add -A
git commit -m "release: vX.Y.Z"
git tag vX.Y.Z
git push && git push --tags
```

## 5. 发布归档（可选）

- 本地归档目录：`E:\Backup\Releases\vps-toolkit`（仅本地，不入 Git）。
- GitHub Release 可附带打包的 `setup.sh` 或源码压缩包。`.gitignore` 已忽略 `dist/`、`build/`、`releases/`、`*.zip`、`*.tar.gz`。

## 构建一致性（建议）

发布前确认提交的 `setup.sh` 确为最新构建：

```bash
cp setup.sh /tmp/_committed.sh
bash build.sh
diff /tmp/_committed.sh setup.sh && echo "setup.sh 与源码一致"
```

## 版本策略

当前处于 `0.x` 阶段，**暂不发布正式 v1.0.0**。路线见 [../ROADMAP.md](../ROADMAP.md)。
