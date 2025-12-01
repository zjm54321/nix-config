{
  pkgs,
  inputs,
  ...
}:
{
  services.displayManager = {
    ly = {
      x11Support = false;
      settings = {
        animation = "colormix";

        bigclock = "en";
        clock = "%Y/%m/%d";

        numlock = true;

        load = true;
        save = true;

        xinitrc = "null";
        text_in_center = true;
        tty = 1;
      };
    };
  };
}
