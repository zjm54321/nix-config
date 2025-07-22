{
  inputs,
  pkgs,
  secret,
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

      plugins =
        (with inputs.anyrun.packages.${pkgs.system}; [
          applications
          shell
          translate
          websearch
        ])
        ++ (with inputs.nur.legacyPackages.${pkgs.system}.repos.zjm54321; [
          anyrun-weather
          anyrun-qalculate
        ]);
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
    extraConfigFiles."weather.ron".text = ''
      Config(
        use_ip_location: true,
        prefix: "&",
        weather_location: GeoLocation(
          lat: 31.23,
          lon: 121.47
        ),
        openweatherapi_key: "${secret.OpenWeatherApi_key}",
        units: Metric
      )
    '';
  };
  home.packages = with pkgs; [ libqalculate ];
}
