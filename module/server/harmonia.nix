/*
  harmonia 是 NixOS 的 Binary Cache 服务配置模块。
  它提供了 NixOS 系统的二进制缓存功能，允许用户从远程服务器获取已编译的 Nix 包，以加快系统构建。
  教程： https://github.com/nix-community/harmonia
  初始步骤：
    - `mkdir /var/lib/secrets ; cd /var/lib/secrets`
    - `nix-store --generate-binary-cache-key <你的 binary cache 地址> harmonia.secret harmonia.pub`
    - `chmod 600 harmonia.secret`
    - `cat harmonia.pub`
*/
{
  config,
  lib,
  ...
}:
with lib;
{

  options.server.nix-binary-cache.harmonia.enable = mkEnableOption "harmonia binary cache 服务";

  config = mkIf config.server.nix-binary-cache.harmonia.enable {
    # 启用 harmonia binary cache 服务
    services.harmonia = {
      enable = true;
      signKeyPaths = [ "/var/lib/secrets/harmonia.secret" ];
    };
    # 打开防火墙端口
    networking.firewall.allowedTCPPorts = [ 5000 ];
  };
}
