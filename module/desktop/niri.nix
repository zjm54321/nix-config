{
  vars,
  lib,
  ...
}:
{

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    compositor.customConfig = ''
      animations {
       off
      }
      window-rule {
        open-focused true
      }
      hotkey-overlay {
        skip-at-startup
      }
      environment {
          DMS_RUN_GREETER "1"
      }
      gestures {
        hot-corners {
          off
        }
      }
      layout {
        background-color "#000000"
      }
    '';
    configHome = "/home/${vars.username}";

  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
  programs.niri.enable = true;

  i18n.inputMethod.fcitx5.waylandFrontend = true;

  # dms需要upower
  services.upower.enable = lib.mkDefault true;

  services.power-profiles-daemon.enable = lib.mkDefault true;
  services.accounts-daemon.enable = lib.mkDefault true;
  services.geoclue2.enable = lib.mkDefault true;
}
