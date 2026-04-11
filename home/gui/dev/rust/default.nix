{
  config,
  lib,
  ...
}:
{
  options.dev.rust.enable = lib.mkEnableOption "启用 Rust 开发环境";

  config = lib.mkIf config.dev.rust.enable {
    home.file.".cargo/config.toml".source = ./config.toml;
  };
}
