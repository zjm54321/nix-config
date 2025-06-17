{
  pkgs,
  ...
}:
{
  # https://wiki.archlinux.org/title/KMSCON
  services.kmscon = {
    # 使用 kmscon 作为虚拟控制台，而不是 getty。
    # kmscon 是一个基于 kms/dri 的用户空间虚拟终端实现。
    # 它支持比标准 Linux 控制台 VT 更丰富的功能集，
    # 包括完整的 Unicode 支持，当显卡支持 drm 时应该会快得多。
    fonts = [
      {
        name = "Maple Mono NF CN";
        package = pkgs.maple-mono.NF-CN;
      }
    ];
    extraOptions = "--term xterm-256color";
    extraConfig = "font-size=16";
    # 是否使用 3D 硬件加速来渲染控制台。
    hwRender = true;
  };
}
