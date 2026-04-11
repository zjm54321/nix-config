{
  config,
  lib,
  ...
}:
{

  options.dev.python.enable = lib.mkEnableOption "启用 Python 开发环境";

  config = lib.mkIf config.dev.python.enable {

    programs.uv = {
      enable = true;
    };
  };
}
