{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
  };

  # 复制 auto-complete 目录到配置目录
  xdg.configFile."nushell/auto-complete" = {
    source = ./auto-complete;
    recursive = true;
  };
}
