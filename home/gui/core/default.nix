{
  imports = [
    ./fcitx5.nix
    ./firefox
    ./vscode
    ./wezterm
  ];

  programs.firefox_with_cfg.enable = true;
  programs.vscode.enable = true;
  programs.wezterm_with_cfg.enable = true;
  programs.fcitx5.enable = true;

}
