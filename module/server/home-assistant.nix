{
  config,
  lib,
  ...
}:
with lib;
{
  options.services.hass.enable = mkEnableOption "通过 Podman 容器启用 Home Assistant 服务";

  config = mkIf config.services.hass.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = [ "home-assistant:/config" ];
        pull = "newer"; # 启用自动更新
        environment.TZ = "Asia/Shanghai";
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
