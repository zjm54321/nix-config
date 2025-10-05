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

    ./anyrun.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./mako.nix
    ./waybar
    ./wlogout.nix
  ];

  options.gui.desktop.niri.enable = mkEnableOption "启用niri桌面环境配置";

  config = mkIf config.gui.desktop.niri.enable {
    home.packages = with pkgs; [
      libnotify # 提供 notify-send 命令
      wlr-randr # 用于调整显示器设置
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    # anyrun 配置
    programs.anyrun.enable = true;

    # hyprlock 配置
    programs.hyprlock.enable = true;

    # hypridle 配置
    services.hypridle.enable = true;

    # wlogout 配置 [todo] 使用 wleave 替代
    programs.wlogout.enable = true;

    # 通知设置
    services.mako.enable = true;

    programs.niri.settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      spawn-at-startup = [
        {
          command = [
            "systemctl"
            "--user"
            "restart"
            "waybar.service"
          ];
        }
        {
          command = [
            "${lib.getExe pkgs.swaybg}"
            "-i"
            "${
              (pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/refs/heads/main/wallpapers/brands/gruvbox-rainbow-nix.png";
                hash = "sha256-DK5XTD5XQiabnGJaPZ7hT662UKvNri4cETaoneXC6xw=";
              })
            }"
            "-m"
            "fill"
          ];
        }
        { command = [ "fcitx5" ]; }
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
          { proportion = 1.; }
        ];
        preset-window-heights = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
          { proportion = 1.; }
        ];
        default-column-width.proportion = lib.mkForce (1. / 2.);
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
