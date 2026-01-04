{
  services.hypridle = {
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "niri msg action power-on-monitors";
      };

      listener = [
        {
          timeout = 120; # 2 分钟
          on-timeout = "brightnessctl -s set 1%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 140; # 2 分钟 20 秒
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors && brightnessctl -r";
        }
        {
          timeout = 180; # 3 分钟
          on-timeout = "pidof hyprlock || hyprlock";
          on-resume = "niri msg action power-on-monitors && brightnessctl -r";
        }

      ];
    };
  };
}
