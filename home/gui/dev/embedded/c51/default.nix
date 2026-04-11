{
  config,
  lib,
  ...
}:
{
  options.dev.embedded.c51.enable = lib.mkEnableOption "启用 51 单片机开发环境";

  config = lib.mkIf config.dev.embedded.c51.enable {
    #home.packages = with pkgs; [ dotnet-runtime_6 ];
  };
}
