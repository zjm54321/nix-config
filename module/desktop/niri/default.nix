{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [

  ];

  options = {
    services.display.niri.enable = lib.mkEnableOption "Niri desktop environment";
  };

  config = mkIf config.services.display.niri.enable {
    services.displayManager.defaultSession = "niri";
    programs.niri = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      anyrun # 应用程序启动器
      mako # 通知守护程序
      waybar # 状态栏
      hyprlock # 屏幕锁定器
      xwayland-satellite # XWayland 适配器
    ];

  };
}
