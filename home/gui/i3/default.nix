{
  config,
  ...
}:
let
  # path to your i3 config directory
  i3config = ./config;
  i3status-rust = ./i3status-rust.toml;
in
{
  # i3 配置，基于 https://github.com/endeavouros-team/endeavouros-i3wm-setup
  # 直接从当前文件夹中读取配置文件作为配置内容

  # wallpaper, binary file
  home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;
  home.file.".config/i3/config".source = config.lib.file.mkOutOfStoreSymlink i3config;
  home.file.".config/i3status-rust/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink i3status-rust;
  home.file.".config/i3/keybindings".source = ./keybindings;
  home.file.".config/i3/scripts" = {
    source = ./scripts;
    # copy the scripts directory recursively
    recursive = true;
    executable = true; # make all scripts executable
  };

  # set cursor size and dpi for 1080p monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 96;
  };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

}
