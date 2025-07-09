{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with pkgs.vscode-extensions; [
  # 开源
  arrterian.nix-env-selector # Nix Environment Selector
  jnoortheen.nix-ide # Nix IDE
  esbenp.prettier-vscode # Prettier
])
