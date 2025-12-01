{
  vars,
  ...
}:
{
  imports = [
    ./core
    ./gui
  ];

  # Home Manager 需要一些关于您的信息以及它应该管理的路径。
  home = {
    username = vars.username;

    # 此值确定您的配置与哪个 Home Manager 版本兼容。
    # 这有助于避免在新的 Home Manager 版本引入向后不兼容的更改时出现问题。
    #
    # 您可以在不更改此值的情况下更新 Home Manager。
    # 请参阅 Home Manager 发布说明，了解每个版本中的状态版本更改列表。
    stateVersion = "25.11";
  };

  # 让 Home Manager 安装并管理自身。
  programs.home-manager.enable = true;

}
