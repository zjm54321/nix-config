# ----------------------------------------------------------
# Mihomo 代理配置
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
    services.mihomo = {
      enable = true;
      tunMode = true;
      webui = pkgs.zashboard;
      configFile = "${inputs.mysecrets}/mihomo/mihomo.yaml";
    };
    networking.firewall.trustedInterfaces = [ "Mihomo" ];
  };
}
