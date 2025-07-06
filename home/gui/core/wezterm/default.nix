{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.programs.wezterm_with_cfg.enable = mkEnableOption "启用WezTerm终端模拟器";

  config = mkIf config.programs.wezterm_with_cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./wezterm.lua;
    };

    home.sessionVariables.TERMINAL = "wezterm";

  };
}
