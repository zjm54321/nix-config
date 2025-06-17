{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    starship
  ];

  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;

    settings = pkgs.lib.importTOML ./starship.toml;
  };
}
