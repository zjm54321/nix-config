{
  pkgs-unstable,
  lib,
  ...
}:
{
  services.mako = {
    settings = {
      border-radius = 10;

      default-timeout = 5000; # 5秒

      on-button-left = "invoke-default-action";
      on-button-right = "exec makoctl menu ${lib.getExe pkgs-unstable.rofi} -- -dmenu"; # [fixme] 使用 rofi 2.0 以支持 wayland
      on-touch = "exec makoctl menu ${lib.getExe pkgs-unstable.rofi} -- -dmenu";
    };
  };
}
