{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.programs.firefox_with_cfg.enable = mkEnableOption "启用Firefox浏览器";

  config = mkIf config.programs.firefox_with_cfg.enable {
    programs.firefox = {
      enable = true;
      # languagePacks = [ "zh-CN" ];
    };

    home.sessionVariables.BROWSER = "firefox";
  };
}
