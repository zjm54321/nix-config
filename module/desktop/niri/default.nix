{
  services.displayManager.defaultSession = "niri";
  # enable sway window manager
  programs.niri = {
    # Install the packages from nixpkgs
    # Whether to enable XWayland
    # xwayland.enable = true;
  };
}
