{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sgo3";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    #============================= 背光 =================================
    brightnessctl

    #============================= 音频(PipeWire) =======================
    pulseaudio # 提供 `pactl` 命令，某些应用程序需要此命令（例如 sonic-pi）
  ];

  # PipeWire 是一个新的低级多媒体框架。
  # 它旨在以最小延迟提供音频和视频的捕获和播放功能。
  # 它支持基于 PulseAudio、JACK、ALSA 和 GStreamer 的应用程序。
  # PipeWire 具有出色的蓝牙支持，可以作为 PulseAudio 的良好替代品。
  #     https://nixos.wiki/wiki/PipeWire
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

  #============================= 蓝牙 =============================
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "25.05";

  services.display.desktop = "niri";
  networking.proxy.mihomo.enable = true; # 启用代理
}
