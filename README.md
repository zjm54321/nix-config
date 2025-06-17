# 这是什么？

这是我的个人 NixOS 系统配置，使用 Flakes 进行管理。该配置提供了一套完整的桌面环境和开发工具配置。

# 如何使用？

```bash
# 克隆此仓库
git clone git@github.com:zjm54321/nix-config.git

# 进入配置目录
cd nix-config

# 更新 flake 输入
just up

# 部署系统配置
sudo just deploy
```

# 软件配置

| 组件类型   | 软件名称         |
| ---------- | ---------------- |
| 系统 Shell | nushell          |
| 终端模拟器 | wezterm          |
| 编辑器     | neovim           |
| IDE        | vscodium         |
| 配置管理   | git & nix flakes |

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
