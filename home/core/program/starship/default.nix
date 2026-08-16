{ pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableBashIntegration = false;
    enableNushellIntegration = true;
    settings = pkgs.lib.importTOML ./starship.toml;
  };
}
