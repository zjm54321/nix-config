{
  pkgs,
  ...
}:
{
  programs.helix = {
    enable = true;
    package = pkgs.evil-helix;
  };

  home.shellAliases = {
    vi = "hx";
    vim = "hx";
    nvim = "hx";
  };

  home.sessionVariables.EDITOR = "hx";
}
