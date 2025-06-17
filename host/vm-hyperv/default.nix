{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "vm-hyperv"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  system.stateVersion = "25.05";

  services.display.desktop = "sway"; # Use the core desktop environment

}
