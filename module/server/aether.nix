{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.services.aether;
in
{
  options.services.aether = {
    enable = mkEnableOption "通过 Podman 容器启用 Aether AI API 网关服务";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        aether-postgres = {
          image = "postgres:15";
          environment = {
            POSTGRES_DB = "aether";
            POSTGRES_USER = "postgres";
            POSTGRES_PASSWORD = "aether";
            TZ = "Asia/Shanghai";
          };
          volumes = [ "aether-postgres-data:/var/lib/postgresql/data" ];
          extraOptions = [
            "--health-cmd=pg_isready -U postgres"
            "--health-interval=5s"
            "--health-timeout=5s"
            "--health-retries=5"
            "--network=aether-net"
          ];
        };

        aether-redis = {
          image = "redis:7-alpine";
          cmd = [
            "redis-server"
            "--appendonly"
            "yes"
          ];
          volumes = [ "aether-redis-data:/data" ];
          extraOptions = [
            "--health-cmd=redis-cli --raw incr ping"
            "--health-interval=5s"
            "--health-timeout=3s"
            "--health-retries=5"
            "--network=aether-net"
          ];
        };

        aether-app = {
          image = "ghcr.io/fawney19/aether:latest";
          pull = "newer";
          environment = {
            DATABASE_URL = "postgresql://postgres:aether@aether-postgres:5432/aether";
            REDIS_URL = "redis://aether-redis:6379/0";
            JWT_SECRET_KEY = "aether-jwt-secret-key-internal-2025aa";
            ENCRYPTION_KEY = "aether-encryption-key-internal-2025aa";
            ADMIN_EMAIL = vars.useremail;
            ADMIN_USERNAME = vars.username;
            ADMIN_PASSWORD = "aether";
            GUNICORN_WORKERS = "2";
            TZ = "Asia/Shanghai";
          };
          dependsOn = [
            "aether-postgres"
            "aether-redis"
          ];
          extraOptions = [
            "--publish=8084:80"
            "--network=aether-net"
          ];
        };
      };
    };

    # 创建 podman 网络，使容器间可通过名称互访
    systemd.services.create-aether-network = {
      description = "Create Aether podman network";
      after = [ "podman.service" ];
      wantedBy = [
        "podman-aether-postgres.service"
        "podman-aether-redis.service"
        "podman-aether-app.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${config.virtualisation.podman.package}/bin/podman network exists aether-net || \
        ${config.virtualisation.podman.package}/bin/podman network create aether-net
      '';
    };
  };
}
