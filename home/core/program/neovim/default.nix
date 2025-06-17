{
  config,
  ...
}:
let
  # path to your nvim config directory
  nvimPath = "${config.home.homeDirectory}/nix-config/home/core/program/neovim/nvim";
in
{
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimPath;

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
  };

  home.sessionVariables.EDITOR = "nvim";
}
