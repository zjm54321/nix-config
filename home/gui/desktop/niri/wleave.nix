{
  pkgs,
  ...
}:
{
  programs.wleave = {
    settings = {
      # 基础布局配置
      margin = 50; # 使用 CSS 控制间距，这里设为 0 以避免冲突
      buttons-per-row = "3"; # 6个按钮，分2行显示 (3列)，比单行更符合 Material 的卡片布局
      column-spacing = 16;
      row-spacing = 16;
      delay-command-ms = 200; # 增加一点延迟以展示点击动画
      close-on-lost-focus = true;
      show-keybinds = true;
      no-version-info = true;

      # 按钮配置
      buttons = [
        {
          label = "lock";
          action = "hyprlock";
          text = "锁屏";
          keybind = "l";
          icon = "${pkgs.wleave}/share/wleave/icons/lock.svg";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "休眠";
          keybind = "h";
          icon = "${pkgs.wleave}/share/wleave/icons/hibernate.svg";
        }
        {
          label = "suspend";
          action = "systemctl suspend-then-hibernate";
          text = "混合睡眠";
          keybind = "s";
          icon = "${pkgs.wleave}/share/wleave/icons/suspend.svg";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "注销";
          keybind = "o";
          icon = "${pkgs.wleave}/share/wleave/icons/logout.svg";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "关机";
          keybind = "p";
          icon = "${pkgs.wleave}/share/wleave/icons/shutdown.svg";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "重启";
          keybind = "r";
          icon = "${pkgs.wleave}/share/wleave/icons/reboot.svg";
        }
      ];
    };

    style = ''
      /* Material Design 3 Expressive 风格定义 */

      /* 定义全局颜色变量 (基于 M3 紫色调) */
      @define-color surface-dim #141218;
      @define-color surface-container #211f26;
      @define-color surface-container-high #2b2930;
      @define-color primary #d0bcff;
      @define-color on-primary #381e72;
      @define-color secondary-container #4a4458;
      @define-color on-secondary-container #e8def8;
      @define-color error #f2b8b5;
      @define-color on-surface #e6e1e5;
      @define-color outline #938f99;

      /* 背景窗口 */
      window {
        background-color: rgba(20, 18, 24, 0.85); /* Surface Dim with opacity */
        padding: 0;
      }

      /* 按钮基础样式 */
      button {
        background-color: @surface-container;
        color: @on-surface;
        border: none;
        border-radius: 28px; /* M3 大圆角 (Extra Large shape) */
        padding: 24px;
        margin: 4px;
        transition: all 0.2s cubic-bezier(0.2, 0.0, 0, 1.0); /* 标准 M3 缓动 */
        box-shadow: none;
      }

      /* 悬停状态 (Hover State Layer) */
      button:hover {
        background-color: @surface-container-high;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 提升感 */
        transform: scale(1.02); /* 轻微放大 */
      }

      /* 聚焦状态 (Focus) */
      button:focus {
        border: 2px solid @primary;
        background-color: @surface-container-high;
      }

      /* 激活/点击状态 (Pressed) */
      button:active {
        background-color: @primary;
        color: @on-primary;
        transform: scale(0.96);
        box-shadow: none;
      }

      /* 图标样式 */
      button image {
        margin-bottom: 8px;
        -gtk-icon-effect: none; /* 防止图标变暗 */
      }

      /* 针对不同按钮的图标颜色定制 (可选，保持统一风格或分别着色) */
      button#lock { color: #ffe8b6; }      /* Primary */
      button#hibernate { color: #a8c0ff; } /* Secondary */
      button#suspend { color: #caaff9; }   /* Secondary */
      button#logout { color: #ffcca8; }    /* Error/Warning tone */
      button#shutdown { color: #ff8d8d; }  /* Error tone */
      button#reboot { color: #84ffaa; }    /* Blue tone */

      /* 激活状态下强制图标颜色为 On-Primary */
      button:active#lock,
      button:active#hibernate,
      button:active#suspend,
      button:active#logout,
      button:active#shutdown,
      button:active#reboot {
        color: @on-primary;
      }

      /* 文字标签样式 */
      button label.action-name {
        font-weight: 600;
        font-size: 16px;
        margin-top: 4px;
      }

      /* 快捷键提示样式 */
      button label.keybind {
        font-family: "Maple Mono NF CN", monospace;
        font-size: 12px;
        color: @outline;
        opacity: 0.6;
        margin-right: 4px;
        margin-top: 4px;
      }

      /* 悬停时高亮快捷键 */
      button:hover label.keybind {
        opacity: 1;
        color: @primary;
      }
    '';
  };
}
