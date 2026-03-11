{

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
  };
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
  programs.niri.enable = true;

  security.pam.services.hyprlock = { };
  i18n.inputMethod.fcitx5.waylandFrontend = true;

}
