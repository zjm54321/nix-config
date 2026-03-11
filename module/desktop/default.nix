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
    ./niri.nix
  ];

  options.services.display.desktop = mkOption {
    description = "Desktop environment configuration.";
    type = types.nullOr (
      types.enum [
        "core" # Core desktop environment with basic features
        "niri" # Niri desktop environment
      ]
    );
    default = null;
  };

  config = mkMerge [
    (mkIf (cfg != null) {
      services.display.core.enable = true;
    })
    (mkIf (cfg == "niri") {
      services.display.niri.enable = true;
    })
  ];
}
