{
  pkgs,
  ...
}:
{
  imports = [
    ../../home
    ../../home/gui
    ../../home/gui/niri
  ];

  home.packages = with pkgs; [
    remmina
  ];
}
