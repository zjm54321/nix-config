{
  pkgs,
  nix-vscode-extensions,
  lib,
  config,
  ...
}:
with lib;
let
  cfgname = "c51";
  cfg = config.vscode.embedded.${cfgname};
in
{
  options.vscode.embedded.${cfgname}.enable = mkEnableOption "启用 VSCode C51 开发配置文件";

  config = mkIf cfg.enable {
    programs.vscode.profiles.${cfgname} = {
      extensions =
        (import ./extensions.nix { inherit nix-vscode-extensions pkgs; })
        ++ (import ./../../../../core/vscode/extensions.nix { inherit nix-vscode-extensions pkgs; })
        ++ (import ./../../../nix/vscode/extensions-default.nix { inherit nix-vscode-extensions pkgs; });

      userSettings = importJSON ./settings.json;
    };
  };
}
