{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
with lib;
let
  # 获取 RIME-LMDG LTS 版本
  rime-lmdg-lts = pkgs.linkFarm "rime-lmdg-lts" [
    {
      name = "wanxiang-lts-zh-hans.gram";
      path = pkgs.fetchurl {
        url = "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram";
        sha256 = "wMr+Mk9xSBL/ifd/D/d85yQXkqDf/PKBiOPeruQxJ7w=";
      };
    }
  ];
  # 合并所有 rime 配置源 (后面的会覆盖前面的同名文件)
  merged-rime-config = pkgs.symlinkJoin {
    name = "merged-rime-config";
    paths = [
      inputs.rime-config # 基础配置(https://www.mintimate.cc/zh/guide/)
      rime-lmdg-lts # LMDG 词库
      inputs.my-rime-config # 个人配置 (优先级最高，会覆盖前面的同名文件)
    ];
  };
in
{
  options.programs.fcitx5.enable = lib.mkEnableOption "启用 Fcitx5 输入法框架";

  config = mkIf config.programs.fcitx5.enable {
    # rime 配置文件
    xdg.dataFile = {
      "fcitx5/rime" = {
        source = merged-rime-config;
        # 强制替换以确保 rime 配置始终是最新的
        force = true;
        recursive = true;
      };
    };

    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx5";
    };

    /*
      不需要这个服务(由 XDGautostart 配置)
      这个服务会在 niri 启动前提前启动 fcitx5，导致 dbus 卡住，并影响 waybar 的加载
      现在会通过 niri 的启动脚本来启动 fcitx5
    */
    systemd.user.services."app-org.fcitx.Fcitx5@autostart" = lib.mkForce { };
  };
}
