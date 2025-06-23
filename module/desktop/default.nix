{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.display.desktop;
in
{
  imports = [
    ./core
    ./i3
    ./niri
  ];

  options.services.display.desktop = mkOption {
    description = "Desktop environment configuration.";
    type = types.nullOr (
      types.enum [
        "core" # Core desktop environment with basic features
        "i3" # i3 window manager
        "niri" # Niri desktop environment
        "sway" # Sway window manager
      ]
    );
    default = null;
  };

  config = mkMerge [
    (mkIf (cfg != null) {
      services.display.core.enable = true;
    })
    (mkIf (cfg == "i3") {
      services.xserver.enable = true;
      services.xserver.windowManager.i3.enable = true;
    })
    (mkIf (cfg == "niri") {
      services.display.niri.enable = true;
    })
    (mkIf (cfg == "sway") {
      programs.sway.enable = true;
      programs.sway.wrapperFeatures.gtk = true;
    })
  ];
}
