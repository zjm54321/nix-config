{
  config,
  lib,
  ...
}:
{
  imports = [ ./vscode ];

  options.dev.rust.enable = lib.mkEnableOption "启用 Rust 开发环境";

  config = lib.mkIf config.dev.rust.enable {
    vscode.rust.enable = true;
    home.file.".cargo/config.toml".source = ./config.toml;
  };
}
