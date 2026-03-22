{ config, ... }:
{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    # [fixme] 目前 nushell 没有提供热加载配置的方式，所以只能强制替换来确保配置更新
    # https://github.com/nix-community/home-manager/issues/4313
    environmentVariables = config.home.sessionVariables;
  };

  # 复制 auto-complete 目录到配置目录
  xdg.configFile."nushell/auto-complete" = {
    source = ./auto-complete;
    recursive = true;
  };
}
