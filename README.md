# 这是什么？

这是我的个人 NixOS 系统配置，使用 Flakes 进行管理。该配置提供了一套完整的桌面环境和开发工具配置。

# 软件配置

| 组件类型   | 软件名称         |
| ---------- | ---------------- |
| 系统 Shell | nushell          |
| 终端模拟器 | wezterm          |
| 编辑器     | neovim           |
| IDE        | vscodium         |
| 配置管理   | git & nix flakes |


# 如何使用？

## 更新系统

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

## 全盘加密

### 第一步：重置 TPM

> [!NOTE]
> 如果前一个系统为 Windows 且启用了 Bitlocker ，则需要执行以下步骤
>
> ```bash
> sudo su
> echo 5 > /sys/class/tpm/tpm0/ppi/request
> ```

```bash
# 清除 TPM 状态
sudo tpm2_clear

# 重新初始化 TPM
sudo tpm2_startup -c

# 验证 TPM 状态
sudo tpm2_getcap properties-fixed
```


### 第二步：添加 LUKS 恢复密钥

```bash
# 查看当前 LUKS 分区密码槽
sudo systemd-cryptenroll /dev/nvme0n1p2

# 添加新的恢复密钥
sudo systemd-cryptenroll --recovery-key /dev/nvme0n1p2

# 验证密钥槽
sudo systemd-cryptenroll /dev/nvme0n1p2
```

> [!NOTE]
> **不要忘记保存你的恢复密钥！**

### 第三步：添加 TPM 密钥
```bash
# 启用带安全加密的 TPM 
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/nvme0n1p2

# 或者不使用安全加密
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+12 --wipe-slot=tpm2 /dev/nvme0n1p2

# 验证 TPM 密钥已添加
sudo systemd-cryptenroll /dev/nvme0n1p2
```

> [!WARNING]
> 不使用安全加密无法构建完整的信任链，**存在安全风险**。


### 第四步：删除旧的 LUKS 密钥

```bash
# 删除旧的 LUKS 密钥槽
sudo systemd-cryptenroll --wipe-slot=password /dev/nvme0n1p2

# 验证 LUKS 密钥槽
sudo systemd-cryptenroll /dev/nvme0n1p2
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
