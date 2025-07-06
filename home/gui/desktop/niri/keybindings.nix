{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.gui.desktop.niri.enable {
    programs.niri.settings.binds = with config.lib.niri.actions; {
      # niri 键盘快捷键
      "Mod+Shift+Slash" = {
        hotkey-overlay.title = "快捷键展示";
        action = show-hotkey-overlay;
      };
      "Mod+Shift+E" = {
        hotkey-overlay.title = "退出 Niri";
        action = quit;
      };
      "Ctrl+Alt+Delete".action = quit;
      "Mod+O" = {
        hotkey-overlay.title = "打开预览";
        repeat = false;
        action = toggle-overview;
      };

      # 打开应用程序
      "Mod+Return" = {
        repeat = false;
        hotkey-overlay.title = "打开终端: wezterm";
        action = spawn "wezterm";
      };
      "Mod+Space" = {
        repeat = false;
        hotkey-overlay.title = "运行应用程序: anyrun";
        action = spawn "anyrun";
      };
      "Mod+Alt+L" = {
        repeat = false;
        hotkey-overlay.title = "锁定屏幕: hyprlock";
        action = spawn "hyprlock";
      };

      # 多媒体按键
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action = spawn "brightnessctl" "set" "5%+";
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action = spawn "brightnessctl" "set" "5%-";
      };
      "Print" = {
        hotkey-overlay.title = "截图";
        action = screenshot;
      };

      # 鼠标控制
      "Mod+WheelScrollUp".action = focus-column-left;
      "Mod+WheelScrollDown".action = focus-column-right;

      # 窗口控制
      "Mod+H" = {
        hotkey-overlay.title = "焦点左移";
        action = focus-column-left;
      };
      "Mod+J" = {
        hotkey-overlay.title = "焦点下移";
        action = focus-window-down;
      };
      "Mod+K" = {
        hotkey-overlay.title = "焦点上移";
        action = focus-window-up;
      };
      "Mod+L" = {
        hotkey-overlay.title = "焦点右移";
        action = focus-column-right;
      };

      "Mod+Ctrl+H" = {
        hotkey-overlay.title = "移动列至左侧";
        action = move-column-left;
      };
      "Mod+Ctrl+J" = {
        hotkey-overlay.title = "移动窗口至下方";
        action = move-window-down;
      };
      "Mod+Ctrl+K" = {
        hotkey-overlay.title = "移动窗口至上方";
        action = move-window-up;
      };
      "Mod+Ctrl+L" = {
        hotkey-overlay.title = "移动列至右侧";
        action = move-column-right;
      };
      "Mod+Left".action = focus-column-left;
      "Mod+Down".action = focus-window-down;
      "Mod+Up".action = focus-window-up;
      "Mod+Right".action = focus-column-right;
      "Mod+Ctrl+Left".action = move-column-left;
      "Mod+Ctrl+Down".action = move-window-down;
      "Mod+Ctrl+Up".action = move-window-up;
      "Mod+Ctrl+Right".action = move-column-right;

      "Mod+Q" = {
        hotkey-overlay.title = "关闭窗口";
        action = close-window;
      };
      "Mod+BracketLeft" = {
        hotkey-overlay.title = "向左压入或弹出窗口";
        action = consume-or-expel-window-left;
      };
      "Mod+BracketRight" = {
        hotkey-overlay.title = "向右压入或弹出窗口";
        action = consume-or-expel-window-right;
      };
      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = expel-window-from-column;
      "Mod+R" = {
        hotkey-overlay.title = "切换列宽";
        action = switch-preset-column-width;
      };
      "Mod+Shift+R" = {
        hotkey-overlay.title = "切换列高";
        action = switch-preset-window-height;
      };
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F" = {
        hotkey-overlay.title = "最大化";
        action = maximize-column;
      };
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Ctrl+F".action = expand-column-to-available-width;
      "F11".action = fullscreen-window;

      "Mod+C".action = center-column;
      "Mod+Ctrl+C".action = center-visible-columns;

      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      "Mod+V" = {
        hotkey-overlay.title = "切换窗口浮动模式";
        action = toggle-window-floating;
      };
      "Mod+Shift+V" = {
        hotkey-overlay.title = "浮动与平铺焦点切换";
        action = switch-focus-between-floating-and-tiling;
      };

      "Mod+W".action = toggle-column-tabbed-display;

      # 工作区
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;

      "Mod+U" = {
        hotkey-overlay.title = "焦点移至下一工作区";
        action = focus-workspace-down;
      };
      "Mod+I" = {
        hotkey-overlay.title = "焦点移至上一工作区";
        action = focus-workspace-up;
      };
      "Mod+Ctrl+U" = {
        hotkey-overlay.title = "移动列至下一工作区";
        action = move-column-to-workspace-down;
      };
      "Mod+Ctrl+I" = {
        hotkey-overlay.title = "移动列至上一工作区";
        action = move-column-to-workspace-up;
      };

    };
  };
}
