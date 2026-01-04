{
  # 设置合盖情况
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "ignore";
  };
  systemd.sleep.extraConfig = "HibernateDelaySec=5400"; # 90分钟后休眠
}
