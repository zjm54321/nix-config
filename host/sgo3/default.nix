{
  imports = [
    ./hardware.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sgo3";
  networking.networkmanager.enable = true;

  system.stateVersion = "25.11";

  services.tpm2.enable = true;
  services.display.desktop = "niri";
  services.display.bootanmination.enable = true;
  networking.proxy.mihomo.enable = true; # 启用代理
}
