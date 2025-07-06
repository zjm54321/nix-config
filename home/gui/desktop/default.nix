{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.gui.de;
in
{
  imports = [
    ./i3
    ./niri
  ];

  options.gui.de = mkOption {
    description = "Desktop environment configuration.";
    type = types.nullOr (
      types.enum [
        "i3"
        "niri"
        "sway"
      ]
    );
    default = null;
  };

  config = mkMerge [
    (mkIf (cfg != null) {
      gui.core.enable = true;
    })
    (mkIf (cfg == "i3") {
      gui.desktop.i3.enable = true;
    })
    (mkIf (cfg == "niri") {
      gui.desktop.niri.enable = true;
    })
  ];

}
