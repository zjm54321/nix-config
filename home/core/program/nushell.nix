{
  programs.nushell = {
    enable = true;
    configFile.text = ''
      $env.config.show_banner = false
      $env.config.edit_mode = "vi"
      $env.PROMPT_INDICATOR = "$ "
      $env.PROMPT_INDICATOR_VI_NORMAL = "> "
      $env.PROMPT_INDICATOR_VI_INSERT = "$ "
    '';
  };
}
