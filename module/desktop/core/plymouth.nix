{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.display.bootanmination.enable = lib.mkEnableOption "启用 Plymouth 启动画面。";

  config = mkIf config.services.display.bootanmination.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = mkForce "bgrt";
        logo =
          pkgs.runCommand "nixos-logo-small"
            {
              buildInputs = [ pkgs.imagemagick ];
            }
            ''
              # 下载原图片
              cp ${
                pkgs.fetchurl {
                  url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nixos-white.png";
                  sha256 = "1ljs8ppl7qrnvfczvb0gwk29rlnjys448nj7prl0nkv6kbz3zdnr";
                }
              } original.png
              convert original.png -resize 12% $out
            '';
      };

      # 启用"静默启动"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
      /*
        隐藏引导加载器的操作系统选择
        仍然可以通过按任意键打开引导加载器列表
        只是在按键之前不会显示在屏幕上
      */
      loader.timeout = 0;
    };
  };
}
