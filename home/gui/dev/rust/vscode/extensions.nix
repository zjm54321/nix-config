{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with pkgs.vscode-extensions; [
  rust-lang.rust-analyzer
  vadimcn.vscode-lldb
])
