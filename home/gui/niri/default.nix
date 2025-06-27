{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    anyrun # 应用程序启动器
    libnotify # 提供 notify-send 命令
    xwayland-satellite # XWayland 适配器
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # hyprlock 配置
  programs.hyprlock.enable = true;
  xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;

  # 通知设置
  services.mako.enable = true;

  programs.niri.config = builtins.readFile ./niri.kdl;

}
