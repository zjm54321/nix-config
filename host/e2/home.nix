{
  pkgs,
  ...
}:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    remmina
  ];

  programs = {
    wiliwili.enable = true;
  };
  gui.de = "niri";
}
