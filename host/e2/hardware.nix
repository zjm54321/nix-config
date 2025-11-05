{
  pkgs,
  config,
  vars,
  ...
}:
{
  boot.kernelModules = [
    "ddcci-backlight"
    "kvm-intel"
  ];

  boot.initrd.kernelModules = [
    "dm-raid"
    "raid0"
    "dm-cache-default"
  ];

  # Intel UHD Graphics 630
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-ocl
      vpl-gpu-rt
      libvdpau-va-gl
    ];
  };
  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
    ANV_DEBUG = "video-decode,video-encode";
  };

  #背光
  hardware.i2c.enable = true;
  users.users.${vars.username}.extraGroups = [ "i2c" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];

  services.udev.extraRules =
    let
      bash = "${pkgs.bash}/bin/bash";
      ddcciDev = "AUX B/DDI B/PHY B";
      ddcciNode = "/sys/bus/i2c/devices/i2c-5/new_device";
    in
    ''
      SUBSYSTEM=="i2c", ACTION=="add", ATTR{name}=="${ddcciDev}", RUN+="${bash} -c 'sleep 30; printf ddcci\ 0x37 > ${ddcciNode}'"
    '';

  environment.systemPackages = with pkgs; [
    brightnessctl
    # 音频(PipeWire)
    pulseaudio # 提供 `pactl` 命令，某些应用程序需要此命令（例如 sonic-pi）
  ];
  /*
    PipeWire 是一个新的低级多媒体框架。
    它旨在以最小延迟提供音频和视频的捕获和播放功能。
    它支持基于 PulseAudio、JACK、ALSA 和 GStreamer 的应用程序。
    PipeWire 具有出色的蓝牙支持，可以作为 PulseAudio 的良好替代品。
    https://nixos.wiki/wiki/PipeWire
  */
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # 如果您想使用 JACK 应用程序，请取消注释此行
    jack.enable = true;
    wireplumber.enable = true;
  };
  # rtkit 是可选的，但建议启用
  security.rtkit.enable = true;
  # 禁用 pulseaudio，因为它与 pipewire 冲突。
  services.pulseaudio.enable = false;

  # 蓝牙
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # 打印机
  services.printing = {
    enable = true;
    openFirewall = true;
    drivers = [ pkgs.hplip ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # 虚拟化
  boot.extraModprobeConfig = "options kvm_intel nested=1";
}
