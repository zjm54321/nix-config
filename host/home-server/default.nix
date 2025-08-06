{
  imports = [
    ./hardware.nix
    ./hardware-configuration.nix
    ./server.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "home-server";
  networking.networkmanager.enable = true;

  system.stateVersion = "25.05";

}
