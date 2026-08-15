{
  wsl = {
    enable = true;
    defaultUser = "ming";
    interop.includePath = true;
    useWindowsDriver = true;
    wslConf = {
      automount.root = "/mnt";
      boot.systemd = true;
      interop = {
        enabled = true;
        appendWindowsPath = true;
      };
    };
  };
}
