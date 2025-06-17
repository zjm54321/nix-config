{
  lib,
  ...
}:
{
  nixpkgs.config.allowUnfree = lib.mkForce true;

  nix = {
    # 每周进行垃圾收集以保持较低的磁盘使用率
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    # 通过 `nix.settings` 声明式地自定义 /etc/nix/nix.conf
    settings = {
      # 全局启用 flakes
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        # 位于中国的缓存镜像
        # 状态: https://mirror.sjtu.edu.cn/
        #"https://mirror.sjtu.edu.cn/nix-channels/store"
        # 状态: https://mirrors.ustc.edu.cn/status/
        "https://mirrors.ustc.edu.cn/nix-channels/store"

        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      builders-use-substitutes = true;

      # 手动优化存储：nix-store --optimise
      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
      auto-optimise-store = true;
    };

    channel.enable = false; # 移除 nix-channel 相关工具和配置，我们使用 flakes 代替
  };
}
