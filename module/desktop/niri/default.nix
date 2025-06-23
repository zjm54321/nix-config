{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [

  ];

  options = {
    services.display.niri.enable = lib.mkEnableOption "Niri desktop environment";
  };

  config = mkIf config.services.display.niri.enable {
    services.displayManager.defaultSession = "niri";
    programs.niri.enable = true;
    security.pam.services.hyprlock = { };
  };
}
