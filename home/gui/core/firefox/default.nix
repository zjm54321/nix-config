{
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    firefox
  ];

  programs.firefox = {
    enable = true;
    # languagePacks = [ "zh-CN" ];

  };

  home.sessionVariables.BROWSER = "firefox";
}
