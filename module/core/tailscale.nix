{
  pkgs-unstable,
  ...
}:
/*
  Tailscale - 基于 WireGuard 的私有网络(VPN)

  它是开源的，个人使用免费，
  而且设置和使用都非常简单。
  Tailscale 对 Linux、Windows、Mac、Android 和 iOS 都有很好的客户端支持。
  相比其他替代方案如 netbird/netmaker，Tailscale 更加成熟和稳定。
  也许当它们更成熟时我会尝试 netbird/netmaker，但现在我坚持使用 Tailscale。

  使用方法：
   1. 在 https://login.tailscale.com 创建 Tailscale 账户
   2. 通过 `tailscale login` 登录
   3. 通过 `tailscale up --accept-routes` 加入你的 Tailscale 网络
   4. 如果你喜欢自动连接到 Tailscale，使用下面配置中的 `authKeyFile` 选项。

  状态数据：
    `journalctl -u tailscaled` 显示 tailscaled 的日志
    日志显示 tailscale 将数据存储在 /var/lib/tailscale
    通过 impermanence.nix 实现重启后持久化

  参考资料：
  https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/networking/tailscale.nix
*/
{
  # 由于 stable 版本无法编译，因此使用 unstable 版本 [fixme]
  # 让用户可以使用 tailscale 命令
  environment.systemPackages = [ pkgs-unstable.tailscale ];

  # 启用 tailscale 服务
  services.tailscale = {
    package = pkgs-unstable.tailscale;
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # 允许 Tailscale UDP 端口通过防火墙
    openFirewall = true;
    useRoutingFeatures = "client";
    extraUpFlags = "--accept-routes";
    # authKeyFile = "/var/lib/tailscale/authkey";
  };

  networking.firewall.trustedInterfaces = ["tailscale0"];
}
