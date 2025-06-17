{
  pkgs,
  ...
}:
{
  # i3相关选项
  environment.pathsToLink = [ "/libexec" ]; # 将派生项中的/libexec链接到/run/current-system/sw
  services.displayManager.defaultSession = "none+i3";
  services.xserver = {

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      extraPackages = with pkgs; [
        rofi # 应用程序启动器，与dmenu功能相同
        dunst # 通知守护程序
        i3status-rust # 状态栏
        i3lock # 默认i3屏幕锁定器
        xautolock # 一段时间后锁定屏幕
        picom # 透明度和阴影效果
        feh # 设置壁纸
        acpi # 电池信息
        arandr # 屏幕布局管理器
        dex # 自动启动应用程序
        xbindkeys # 将按键绑定到命令
        xorg.xbacklight # 控制屏幕亮度
        xorg.xdpyinfo # 获取屏幕信息
        sysstat # 获取系统信息
      ];
    };

    # 在X11中配置键盘映射
    xkb.layout = "us";
    xkb.variant = "";

    excludePackages = [ pkgs.xterm ];
  };

  # thunar文件管理器(xfce的一部分)相关选项
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # 挂载、回收站和其他功能
  services.tumbler.enable = true; # 图像缩略图支持
}
