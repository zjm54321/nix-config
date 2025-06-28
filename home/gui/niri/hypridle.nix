{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "niri msg action power-on-monitors";
      };

      listeners = [
        {
          timeout = 60; # 1 minute
          on-timeout = "brightnessctl -q set 1%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 300; # 5 minutes
          on-timeout = "pidof hyprlock || hyprlock";
          on-resume = "niri msg action power-on-monitors";
        }
        {
          timeout = 360; # 6 minutes
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors && brightnessctl -r";
        }
        {
          timeout = 600; # 10 minutes
          on-timeout = "systemctl hibernate";
          on-resume = "niri msg action power-on-monitors && brightnessctl -r";
        }
      ];
    };
  };
}
