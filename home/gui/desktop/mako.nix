{
  pkgs,
  lib,
  ...
}:
{
  services.mako = {
    settings = {
      border-radius = 10;

      default-timeout = 5000; # 5秒

      on-button-left = "invoke-default-action";
      on-button-right = "exec makoctl menu ${lib.getExe pkgs.rofi} -- -dmenu";
      on-touch = "exec makoctl menu ${lib.getExe pkgs.rofi} -- -dmenu";
    };
  };
  # [todo] 配置 rofi ，显示为占满全屏的按钮
}
