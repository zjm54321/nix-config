{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with pkgs.vscode-extensions; [
  # 开源
  ms-python.python
  charliermarsh.ruff
  detachhead.basedpyright
])
