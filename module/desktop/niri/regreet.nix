{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.regreet.enable = mkEnableOption "Regreet 服务";

  config = mkIf config.services.regreet.enable {
    programs.regreet = {
      enable = true;
      settings = {
        appearance.greeting_msg = "欢迎！";
        widget.colok = {
          resolution = "1s";
        };
      };
    };
    services.greetd = {
      enable = true;
      settings =
        let
          logincfg = pkgs.writeText "niri-login.conf" ''
            animations {
              off
            }
            hotkey-overlay {
             skip-at-startup
            }
            window-rule {
              open-focused true
            }
          '';
        in
        {
          default_session = {
            user = "greeter";
            command = concatStringsSep " " [
              "${pkgs.dbus}/bin/dbus-run-session --"
              "${getExe pkgs.niri} -c ${logincfg} --"
              "${getExe pkgs.greetd.regreet};"
              "${getExe pkgs.niri} msg action quit --skip-confirmation"
            ];
          };
        };
    };
  };
}
