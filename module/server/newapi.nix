{
  config,
  lib,
  ...
}:
with lib;
{
  options.services.newapi.enable = mkEnableOption "通过 Podman 容器启用 newapi 服务";

  config = mkIf config.services.newapi.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.newapi = {
        # 把主机路径映射到容器的 /data（替换为你的实际路径）
        volumes = [ "newapi:/data" ];
        # 如果希望自动拉取更新，可改为 "newer" 或 "always"
        pull = "newer";
        environment.TZ = "Asia/Shanghai";
        # 官方镜像
        image = "calciumion/new-api:latest";
        # 映射端口 3000:3000
        extraOptions = [
          "--publish=3000:3000"
        ];
      };
    };
  };
}
