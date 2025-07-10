{
  nix-vscode-extensions,
  pkgs,
  ...
}:
(with pkgs.vscode-extensions; [
  # 开源
  ms-ceintl.vscode-language-pack-zh-hans # 中文语言包
  usernamehw.errorlens # Error Lens
  tamasfe.even-better-toml # Even Better TOML
  ms-vscode.hexeditor # Hex Editor
  yzhang.markdown-all-in-one # Markdown All in One
  pkief.material-icon-theme # Material Icon Theme
  zhuangtongfa.material-theme # One Dark Pro
  asvetliakov.vscode-neovim # Neovim
  mkhl.direnv # Direnv
  nefrob.vscode-just-syntax # justfile
  thenuprojectcontributors.vscode-nushell-lang # Nushell
  # 闭源
  github.copilot # Copilot
  github.copilot-chat # Copilot Chat
])
++ (
  # 开源
  with nix-vscode-extensions.extensions.${pkgs.system}.open-vsx; [
    miguelsolorio.fluent-icons # Fluent Icons
    jeanp413.open-remote-ssh # SSH
  ])
++ (
  # 闭源
  with nix-vscode-extensions.extensions.${pkgs.system}.extensions.vscode-marketplace; [
  ])
