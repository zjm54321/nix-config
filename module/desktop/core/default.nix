{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [
    ./fcitx5.nix
    ./fonts.nix
    ./kmscon.nix
    ./ly.nix
    ./plymouth.nix
    ./keymap
  ];

  options = {
    services.display.core.enable = mkEnableOption {
      description = "启用显示核心服务。";
      default = false;
    };
  };

  config = mkIf config.services.display.core.enable {
    # 启用登录管理器
    services.displayManager.enable = mkDefault true;
    services.displayManager.ly.enable = mkDefault true;
    # 启用kmscon作为虚拟控制台
    services.kmscon.enable = true;
    # 启用字体服务
    services.display.core.fonts.enable = true;
    # 启用按键重映射
    services.kanata.enable = mkDefault true;
    # 启用输入法
    services.input.enable = mkDefault true;
  };
}
