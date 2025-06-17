# 桌面核心模块 (Desktop Core Module)

这个模块包含了桌面环境的核心组件配置，包括字体管理、终端仿真器和显示管理器。

## 模块组成

### 1. 字体配置 (`fonts.nix`)

配置系统字体，提供完整的多语言支持和图标字体。

**主要特性:**
- 禁用默认字体包，使用精选字体
- 支持中文显示（思源黑体/宋体）
- 包含 Emoji 表情符号支持
- 提供编程用等宽字体（Maple Mono）
- 集成 Nerd Fonts 图标字体

**字体列表:**
- **图标字体**: Material Design Icons, Font Awesome, Nerd Fonts Symbols
- **表情符号**: Noto Color Emoji  
- **中文字体**: Source Han Sans/Serif (思源黑体/宋体)
- **英文字体**: Source Sans, Source Serif
- **等宽字体**: Maple Mono NF CN

**默认字体配置:**
- 衬线字体: Source Han Serif SC/TC
- 无衬线字体: Source Han Sans SC/TC  
- 等宽字体: Maple Mono NF CN
- 表情符号: Noto Color Emoji

### 2. 终端配置 (`kmscon.nix`)

使用 KMSCON 作为增强型虚拟控制台，替代传统的 getty。

**主要特性:**
- 基于 KMS/DRI 的用户空间虚拟终端
- 完整的 Unicode 支持
- 硬件 3D 加速渲染
- 自定义字体和字号配置

**配置详情:**
- 字体: Maple Mono NF CN
- 字号: 16px
- 终端类型: xterm-256color
- 硬件渲染: 已启用

### 3. 显示管理器配置 (`ly.nix`)

使用 Ly 作为轻量级显示管理器，提供美观的登录界面。

**主要特性:**
- 轻量级 TUI 显示管理器
- 支持动画效果
- 大时钟显示
- 自动保存/加载配置

**界面配置:**
- 动画效果: Matrix 风格
- 大时钟: 启用
- 时钟格式: %Y/%m/%d (年/月/日)
- 数字锁: 启用
- 文本居中: 启用
- TTY: 1

## 相关链接

- [KMSCON Wiki](https://wiki.archlinux.org/title/KMSCON)
- [Ly Display Manager](https://github.com/fairyglade/ly)
- [Noto Fonts](https://fonts.google.com/noto)
- [Source Han Fonts](https://github.com/adobe-fonts/source-han-sans)
- [Maple Mono Font](https://github.com/subframe7536/maple-font)