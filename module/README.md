# NixOS 模块自定义选项说明

## 概述

本配置提供了一系列自定义的 NixOS 模块选项，旨在简化系统配置，提供灵活的桌面环境和网络代理选择。所有选项都采用声明式配置，确保系统状态的可重现性。

## 选项列表

### 1. 网络代理配置

#### `networking.proxy.mihomo.enable`

**类型**: `boolean`  
**默认值**: `false`  
**描述**: 启用 Mihomo 代理服务

**功能详情**:
- 自动配置 `clash-verge-rev` GUI 客户端
- 启用 Mihomo 服务的 TUN 模式
- 自动配置防火墙规则，将 `Mihomo` 接口设为可信接口
- 支持透明代理模式

**配置示例**:
```nix
networking.proxy.mihomo.enable = true;
```

**相关服务**:
- `programs.clash-verge`: GUI 代理客户端
- `services.mihomo`: 核心代理服务
- `networking.firewall.trustedInterfaces`: 防火墙配置

---

### 2. 桌面环境配置

#### `services.display.desktop`

**类型**: `enum` 或 `null`  
**可选值**: `"core"` | `"i3"` | `"niri"` | `"sway"` | `null`  
**默认值**: `null`  
**描述**: 选择要使用的桌面环境

**选项说明**:

##### `"core"` - 核心桌面环境
仅包含基础桌面功能，不包含窗口管理器：
- 字体配置
- 显示管理器 (Ly)
- 虚拟控制台 (KMSCON)
- 键盘重映射 (Kanata)

##### `"i3"` - i3 窗口管理器
完整的 i3 平铺窗口管理器环境：
- 包含所有 `core` 功能
- i3 窗口管理器
- X11 服务
- 相关工具包 (rofi, dunst, i3status-rust 等)

##### `"niri"` - Niri 桌面环境
现代 Wayland 桌面环境：
- 包含所有 `core` 功能
- Niri 桌面环境

##### `"sway"` - Sway 窗口管理器
Wayland 下的 i3 兼容窗口管理器：
- 包含所有 `core` 功能
- Sway 窗口管理器
- GTK 主题支持

**配置示例**:
```nix
services.display.desktop = "i3";
```
