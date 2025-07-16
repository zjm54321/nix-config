{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with pkgs.vscode-extensions; [
  # 开源
  ms-python.python
  charliermarsh.ruff
])
++
  # [todo] 在 25.11 中将其改为 pkgs.vscode-extensions 的版本
  (
    # 开源
    with nix-vscode-extensions.extensions.${pkgs.system}.open-vsx; [
      detachhead.basedpyright
    ])
