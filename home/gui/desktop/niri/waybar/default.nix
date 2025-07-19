{
  lib,
  ...
}:
{
  programs.waybar = {
    settings.mainBar = lib.importJSON ./config.json;
    style = builtins.readFile ./style.css;
  };
  stylix.targets.waybar.enable = false;
}
