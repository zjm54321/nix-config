{
  config,
  lib,
  ...
}:
{
  imports = [ ./vscode ];

  options.dev.python.enable = lib.mkEnableOption "启用 Python 开发环境";

  config = lib.mkIf config.dev.python.enable {
    vscode.python.enable = true;

    programs.uv = {
      enable = true;
    };
  };
}
