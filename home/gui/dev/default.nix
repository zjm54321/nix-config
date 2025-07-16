{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [
    ./nix
    ./rust
    ./python
  ];

  options.dev = {
    # 开发环境选择选项
    environments = mkOption {
      type = types.listOf (
        types.enum [
          "nix"
          "cpp"
          "rust"
          "python"
        ]
      );
      default = [ "nix" ];
      description = "选择要启用的开发环境";
      example = [
        "nix"
        "cpp"
        "rust"
      ];
    };
  };

  config = {
    dev.nix.enable = elem "nix" config.dev.environments;
    dev.rust.enable = elem "rust" config.dev.environments;
    dev.python.enable = elem "python" config.dev.environments;
  };
}
