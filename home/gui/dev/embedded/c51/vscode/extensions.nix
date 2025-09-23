{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with nix-vscode-extensions.extensions.${pkgs.system}.open-vsx; [
  # 开源
  cl.eide
])
++ (with pkgs.vscode-extensions; [
  # 闭源
  ms-vscode.cpptools
])
