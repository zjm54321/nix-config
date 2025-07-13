{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with pkgs.vscode-extensions; [
  # 开源
  esbenp.prettier-vscode # Prettier
])
