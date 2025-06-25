{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options = {
    services.input.enable = mkEnableOption "Input method support";
  };

  config = mkIf config.services.input.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          # 用于rime中文输入法
          fcitx5-rime
          # 安装后需要使用配置工具启用 rime
          fcitx5-configtool
          fcitx5-chinese-addons
          fcitx5-gtk # gtk 输入法模块
        ];

        settings = {
          inputMethod = {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "rime";
            };
            "Groups/0/Items/0".Name = "rime";
          };
        };
      };
    };

    nixpkgs.overlays = [
      (final: prev: {
        librime =
          (prev.librime.override {
            plugins = with pkgs; [
              librime-lua
              librime-octagram
            ];
          }).overrideAttrs
            (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.luajit ]; # 用luajit
            });
      })
    ];
  };
}
