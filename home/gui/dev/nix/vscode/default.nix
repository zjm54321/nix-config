{
  pkgs,
  nix-vscode-extensions,
  lib,
  config,
  ...
}:
with lib;
let
  cfgname = "nix";
  cfg = config.vscode.${cfgname};
in
{
  options.vscode.${cfgname}.enable = mkEnableOption "启用 VSCode Nix 开发配置文件";

  config = mkIf cfg.enable {
    programs.vscode.profiles.${cfgname} = {
      extensions =
        (import ./extensions.nix { inherit nix-vscode-extensions pkgs; })
        ++ (import ./../../../core/vscode/extensions.nix { inherit nix-vscode-extensions pkgs; })
        ++ (import ./extensions-default.nix { inherit nix-vscode-extensions pkgs; });
      userSettings = { };
      keybindings = importJSON ./keybindings.json;
      userTasks = importJSON ./tasks.json;
    };

    programs.vscode.profiles.default = {
      extensions = import ./extensions-default.nix { inherit nix-vscode-extensions pkgs; };
      userSettings = importJSON ./settings-default.json;
    };
  };
}
