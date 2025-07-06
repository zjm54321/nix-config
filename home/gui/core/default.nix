{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [
    ./fcitx5.nix
    ./firefox
    ./vscode
    ./wezterm
  ];

  options.gui.core.enable = mkEnableOption "启用GUI核心配置";

  config = mkIf config.gui.core.enable {
    programs.firefox_with_cfg.enable = true;
    programs.vscode.enable = true;
    programs.wezterm_with_cfg.enable = true;
    programs.fcitx5.enable = true;
  };
}
