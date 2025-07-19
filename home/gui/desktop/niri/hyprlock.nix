{
  programs.hyprlock = {
    settings = {
      general = {
        hide_cursor = true;
      };

      /*
        取消注释以启用指纹身份验证
            auth = {
              fingerprint = {
                enabled = true;
                ready_message = "Scan fingerprint to unlock";
                present_message = "Scanning...";
                retry_delay = 250; # 以毫秒为单位
              };
            };
      */

      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
          "inputFieldDots, 1, 2, linear"
        ];
      };

      background = {
        monitor = "";
        path = "screenshot";
        blur_passes = 1;
      };

      input-field = {
        monitor = "";
        size = "20%, 5%";
        outline_thickness = 3;
        fade_on_empty = true;
        rounding = -1;

        font_family = "Maple Mono NF CN";
        placeholder_text = "󰀄 $USER";
        fail_text = "$FAIL";

        dots_spacing = 0.3;

        position = "0, 75";
        halign = "center";
        valign = "bottom";
      };

      # 时间
      label = [
        {
          monitor = "";
          text = "$TIME";
          # 参考：https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
          font_size = 240;
          font_family = "IBM Plex Sans Medium";

          position = "0, 0";
          halign = "center";
          valign = "center";
        }
        # 日期
        {
          monitor = "";
          text = "cmd[update:60000] date +\"%Y-%m-%d\"";
          font_size = 25;
          font_family = "Maple Mono NF CN";

          position = "0, -20";
          halign = "center";
          valign = "top";
        }
      ];
    };
  };
}
