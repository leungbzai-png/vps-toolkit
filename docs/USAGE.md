# 使用说明 / Usage

## 前置条件

- Debian / Ubuntu（主要支持），或其他兼容系统
- **root** 权限
- 已安装 `bash`、`curl`

## 运行方式

### 方式一：一键运行（推荐普通用户）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/leungbzai-png/vps-toolkit/main/setup.sh)
```

### 方式二：下载后运行

```bash
curl -fsSL -o setup.sh https://raw.githubusercontent.com/leungbzai-png/vps-toolkit/main/setup.sh
chmod +x setup.sh
./setup.sh
```

### 方式三：从源码运行（开发者）

```bash
git clone https://github.com/leungbzai-png/vps-toolkit.git
cd vps-toolkit
bash build.sh     # 由 lib/ + modules/ 生成 setup.sh
bash setup.sh
```

> `setup.sh` 是 `build.sh` 的生成产物。直接 `bash setup.sh` 即可运行；它是自包含的单文件，**运行时不依赖 lib/ 与 modules/**。

## 启动流程

运行后依次：

1. **选择语言**（简体中文 / 繁體中文 / English / 日本語，默认简体中文）
2. 自动**检测系统与已安装组件**
3. 进入**主菜单**，按编号选择功能（菜单项说明见 [COMMANDS.md](COMMANDS.md)）

## 重要提醒

- 任何涉及 **SSH / 防火墙 / DNS / 删除数据** 的操作前，请先做**快照或备份**（见 [../SECURITY.md](../SECURITY.md)）。
- 修改 SSH 端口或禁用密码登录后，**先用新窗口验证能登录**，再关闭当前窗口。
- 部署服务后，账号/密码等会写入 `/root/deploy_info.txt`，可用主菜单「查看部署信息」查看。

## 退出

主菜单输入 `0` 退出。
