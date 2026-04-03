# 这是什么？

这是我的个人 NixOS 系统配置，使用 Flakes + Home Manager 进行声明式管理。该配置提供了完整的桌面环境、开发工具链和服务器服务配置，支持多主机部署。

# 主机

| 主机名 | 类型 | 桌面环境 | 说明 |
| --- | --- | --- | --- |
| e2 | 台式机 (Intel) | Niri (Wayland) | Secure Boot、KVM 虚拟化、嵌入式开发 |
| sgo3 | Surface Go 3 | Niri (Wayland) | 便携设备，含温控管理 |
| vm-wsl | WSL 虚拟机 | i3 (X11) | 通过 xrdp 提供远程桌面 |

# 软件配置

| 组件类型 | 软件名称 |
| --- | --- |
| 系统 Shell | Nushell + Starship |
| 终端模拟器 | WezTerm |
| 编辑器 | Helix |
| IDE | VSCodium |
| 浏览器 | Firefox |
| 输入法 | Fcitx5 (Rime) |
| VPN | Tailscale |
| 代理 | Mihomo (TUN 模式) |
| AI 工具 | OpenCode、Claude Code |
| 配置管理 | Git & Nix Flakes |

# 目录结构

```
nix-config/
├── flake.nix              # Flake 入口，定义所有主机和输入
├── vars/                  # 全局变量（用户名、SSH 密钥等）
├── module/                # NixOS 系统模块
│   ├── core/              # 核心：网络、SSH、用户、Nix、安全、电源等
│   ├── desktop/           # 桌面：Niri、字体、输入法、Plymouth、虚拟化等
│   ├── dev/               # 开发：嵌入式工具 (probe-rs)
│   └── server/            # 服务器：Aether、Harmonia、Home Assistant 等
├── home/                  # Home Manager 用户配置
│   ├── core/              # Shell、Git、GPG、SSH、Helix、AI/MCP
│   ├── gui/               # VSCode、Firefox、WezTerm、桌面快捷键
│   └── tui/               # OpenCode、Claude Code、Taskwarrior
├── host/                  # 各主机的特定配置和硬件声明
│   ├── e2/
│   ├── sgo3/
│   └── vm-wsl/
└── secrets/               # 密钥管理（通过私有仓库引入）
```

# 特性

- **安全加固**：Secure Boot (Lanzaboote)、TPM2、GPG 智能卡认证、sudo-rs、纯 SSH 密钥认证
- **桌面环境**：Niri (Wayland 平铺式)，支持 Stylix 主题、Plymouth 启动画面、Kanata 按键重映射
- **开发环境**：Nix、Rust、Python、嵌入式 (C51/probe-rs)，按主机按需启用
- **服务器服务**：Aether AI 网关、Harmonia Binary Cache、Home Assistant、qBittorrent、Samba、WebDAV
- **AI 工具链**：OpenCode + Claude Code，集成 MCP Servers (GitHub、NixOS、Context7)
- **网络**：Tailscale 组网 + Mihomo 透明代理，mihomo 在 tailscaled 之后启动

# 如何使用？

## 安装系统

配合我的另一个项目 [NixOS-LiveCD-CN](https://github.com/zjm54321/NixOS-LiveCD-CN) 来快速安装。

详细的安装步骤可以参考 [这里](https://github.com/zjm54321/NixOS-LiveCD-CN/wiki/Install)。

## 日常操作

```bash
# 克隆此仓库
git clone git@github.com:zjm54321/nix-config.git
cd nix-config

# 更新所有 flake 输入
just up

# 部署系统配置
just deploy

# 远程部署到其他主机
just remote <config> <target_host> <build_host>

# 清理旧代数（7 天以前）
just clean

# 垃圾收集未使用的 store 条目
just gc

# 格式化 nix 文件
just fmt
```

# 许可证

我是以下免责声明的每个文件的作者：
```bash
# @author zjm54321
```

我根据 [GNU GPL-3.0](./LICENSE) 许可证对它们进行许可。在适用法律允许的范围内，不提供任何保证。

一些脚本或配置文件来自其他人，应该标注对相应作者的致谢。

# 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！

# 联系方式

- GitHub: [@zjm54321](https://github.com/zjm54321)
- Codeberg: [@zjm54321](https://codeberg.org/zjm54321)
