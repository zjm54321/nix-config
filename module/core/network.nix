# ----------------------------------------------------------
# Mihomo 代理配置
# [todo] 将clash-verge-rev改为mihomo+clashtui
# https://github.com/JohanChane/clashtui/blob/main/README_ZH.md
# ----------------------------------------------------------
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
{

  options = {
    networking.proxy.mihomo.enable = mkEnableOption "启用代理";
  };

  config = mkIf config.networking.proxy.mihomo.enable {
    /*
      programs.clash-verge = {
         enable = true;
         package = pkgs.clash-verge-rev;
         autoStart = true;
       };
    */
    services.mihomo = {
      enable = true;
      tunMode = true;
      webui = pkgs.zashboard;
      configFile = "${inputs.mysecrets}/mihomo/mihomo.yaml";
    };
    networking.firewall.trustedInterfaces = [
      "Mihomo"
      "Meta"
    ];
  };
}
