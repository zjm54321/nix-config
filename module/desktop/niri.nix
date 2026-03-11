{
  config,
  lib,
  ...
}:
with lib;
{

  options = {
    services.display.niri.enable = lib.mkEnableOption "Niri desktop environment";
  };

  config = mkIf config.services.display.niri.enable {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
    };
    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    security.pam.services.hyprlock = { };
    i18n.inputMethod.fcitx5.waylandFrontend = true;
  };
}
