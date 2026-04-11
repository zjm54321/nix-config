# ----------------------------------------------------------
# Mihomo 代理配置
# 访问 http://proxy.localhost/ 即可访问 Mihomo 的 WebUI
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
      webui = pkgs.metacubexd;
      configFile = "${inputs.mysecrets}/mihomo/mihomo-cloud.yaml";
    };

    services.nginx = {
      enable = true;
      virtualHosts."proxy.localhost" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 80;
          }
        ];
        locations."= /" = {
          return = "302 /ui/";
        };
        locations."/" = {
          proxyPass = "http://127.0.0.1:9097";
          proxyWebsockets = true;
        };
      };
    };

    networking.firewall.trustedInterfaces = [ "Mihomo" ];
    systemd.services."mihomo" = {
      after = lib.mkForce [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [ "tailscaled.service" ];

      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      };
    };
  };
}
