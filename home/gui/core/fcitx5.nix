{
  lib,
  inputs,
  ...
}:
{
  # rime 配置文件 [todo] 更改为一个优雅的实现
  xdg.dataFile = {
    "fcitx5/rime" = {
      source = inputs.my-rime-config;
      # 强制替换以确保 rime 配置始终是最新的
      force = true;
      recursive = true;
    };
  };

  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx5";
  };
  # 不需要这个服务
  systemd.user.services."app-org.fcitx.Fcitx5@autostart" = lib.mkForce { };
}
