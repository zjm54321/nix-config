{
  pkgs,
  inputs,
  ...
}:
{
  services.displayManager = {
    ly = {
      # package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.ly; # [todo] 版本为1.1.0
      #x11Support = false;
      settings = {
        #animation = "colormix";

        #bigclock = "en"; 在下个版本中修复
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
