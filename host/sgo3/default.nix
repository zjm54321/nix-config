{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sgo3"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.proxy.mihomo.enable = true; # 启用代理

  system.stateVersion = "25.05"; # Did you read the comment?

  services.display.desktop = "niri";
}
