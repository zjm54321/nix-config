{
  programs.wlogout = {
    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "锁屏";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "休眠";
        keybind = "h";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "睡眠";
        keybind = "s";
      }
      {
        label = "logout";
        action = "loginctl terminate-user $USER";
        text = "注销";
        keybind = "o";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "关机";
        keybind = "p";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "重启";
        keybind = "r";
      }
    ];
  };
}
