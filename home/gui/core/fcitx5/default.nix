{
  pkgs,
  ...
}:
{
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile;
      # 每次 fcitx5 切换输入法时，都会修改 ~/.config/fcitx5/profile 文件，
      # 所以我们需要在每次重新构建时强制替换它以避免文件冲突。
      force = true;
    };
    "fcitx5/config".source = ./config;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        # 用于rime中文输入法
        fcitx5-rime
        # 安装后需要使用配置工具启用 rime
        fcitx5-configtool
        fcitx5-chinese-addons
        fcitx5-gtk # gtk 输入法模块
      ];
    };

  };
}
