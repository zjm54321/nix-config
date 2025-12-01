{
  lib,
  ...
}:
with lib;
{
  imports = [ ./wsl.nix ];
  networking.hostName = "vm-wsl";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "i3";
    port = 3390;
  };

  system.stateVersion = "25.11";

  services.display.desktop = "i3"; # Use the core desktop environment
  services.kanata.enable = mkForce false; # wsl 下无需 kanata

}
