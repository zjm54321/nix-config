{
  pkgs,
  lib,
  config,

  ...
}:
with lib;
{
  imports = [
    ./keybindings.nix

    ./hypridle.nix
    ./waybar
    ./wlogout.nix
  ];

  options.gui.desktop.niri.enable = mkEnableOption "启用niri桌面环境配置";

  config = mkIf config.gui.desktop.niri.enable {
    home.packages = with pkgs; [
      anyrun # 应用程序启动器
      libnotify # 提供 notify-send 命令
      xwayland-satellite # XWayland 适配器
      wlr-randr # 用于调整显示器设置
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    # hyprlock 配置
    programs.hyprlock.enable = true;
    xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;

    # hypridle 配置
    services.hypridle.enable = true;

    # wlogout 配置
    programs.wlogout.enable = true;

    # 通知设置
    services.mako.enable = true;

    programs.niri.settings = {
      environment = {
        DISPLAY = ":0";
      };

      spawn-at-startup = [
        {
          command = [
            "systemctl"
            "--user"
            "restart"
            "waybar.service"
          ];
        }
        { command = [ "fcitx5" ]; }
        { command = [ "xwayland-satellite" ]; }
        { command = [ "wezterm" ]; }
      ];

      # https://github.com/YaLTeR/niri/wiki/Configuration:-Input
      input.keyboard.numlock = true;
      input.focus-follows-mouse.enable = true;
      # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout
      layout = {
        gaps = lib.mkForce 12;
        center-focused-column = "on-overflow";

        preset-column-widths = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
        ];
        preset-window-heights = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
        ];
        default-column-width.proportion = lib.mkForce 1. / 2.;
      };

      prefer-no-csd = true;

      window-rules = [
        {
          clip-to-geometry = true;
          geometry-corner-radius = {
            top-left = 16.0;
            top-right = 16.0;
            bottom-left = 16.0;
            bottom-right = 16.0;
          };
        }
        {
          matches = [ { app-id = "^org\.wezfurlong\.wezterm$"; } ];
          default-column-width = { };
        }
        {
          matches = [
            {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
        }
      ];
    };
  };

}
