{
  imports = [
    ./fcitx5.nix
    ./firefox
    ./wezterm
    ./zed
  ];

  programs.firefox_with_cfg.enable = true;

  programs.wezterm_with_cfg.enable = true;
  programs.fcitx5.enable = true;
  programs.zed-editor.enable = true;

}
