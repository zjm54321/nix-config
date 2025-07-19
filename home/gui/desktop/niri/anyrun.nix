{
  inputs,
  pkgs,
  ...
}:
{
  programs.anyrun = {
    extraCss = null;
    config = {
      x.fraction = 0.5;
      y.fraction = 0.3;
      width.fraction = 0.5;
      hidePluginInfo = true;

      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications
        shell
        websearch
      ];
    };
    extraConfigFiles."shell.ron".text = ''
      Config(
      prefix: "$",
      )'';
    extraConfigFiles."websearch.ron".text = ''
      Config(
        prefix: "?",
        engines: [DuckDuckGo] 
      )'';
  };
}
