{
  pkgs,
  nix-vscode-extensions,
  lib,
  config,
  ...
}:
with lib;
let
  cfgname = "python";
  cfg = config.vscode.${cfgname};
in
{
  options.vscode.${cfgname}.enable = mkEnableOption "启用 VSCode Python 开发配置文件";

  config = mkIf cfg.enable {
    programs.vscode.profiles.${cfgname} = {
      extensions =
        (import ./extensions.nix { inherit nix-vscode-extensions pkgs; })
        ++ (import ./../../../core/vscode/extensions.nix { inherit nix-vscode-extensions pkgs; })
        ++ (import ./../../nix/vscode/extensions-default.nix { inherit nix-vscode-extensions pkgs; });

      userSettings = importJSON ./settings.json;
    };
  };
}
