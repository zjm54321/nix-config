{
  services.mako = {
    settings = {
      border-radius = 10;

      default-timeout = 5000; # 5秒

      on-button-left = "invoke-default-action";
      on-button-right = "dismiss";
      on-touch = "invoke-default-action";
    };
  };
}
