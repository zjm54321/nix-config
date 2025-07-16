{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with pkgs.vscode-extensions; [
  # 开源
  ms-python.python
  ms-python.debugpy
  ms-python.black-formatter
  ms-python.pylint
  # 闭源
  ms-python.vscode-pylance
])
