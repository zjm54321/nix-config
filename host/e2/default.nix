{
  imports = [
    ./hardware.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "e2";
  networking.networkmanager.enable = true;

  system.stateVersion = "25.05";

  services.display.desktop = "niri";
  services.secureboot.enable = true;
  services.tpm2.enable = true;
  services.display.bootanmination.enable = true;
  networking.proxy.mihomo.enable = true; # 启用代理
  dev.probe-rs.enable = true;
  kvm.enable = true; # 启用 KVM 虚拟化支持
}
