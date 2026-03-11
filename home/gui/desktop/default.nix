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
    ./niri
  ];

  options.gui.de = mkOption {
    description = "Desktop environment configuration.";
    type = types.nullOr (
      types.enum [
        "niri"
      ]
    );
    default = null;
  };

  config = mkMerge [
    (mkIf (cfg != null) {
      gui.core.enable = true;
    })
    (mkIf (cfg == "niri") {
      gui.desktop.niri.enable = true;
    })
  ];

}
