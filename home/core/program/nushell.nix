{
  programs.nushell = {
    enable = true;
    configFile.text = ''
      $env.config.show_banner = false
      $env.config.edit_mode = "vi"
      $env.config.cursor_shape.emacs = "block"
      $env.config.cursor_shape.vi_insert = "line"
      $env.config.cursor_shape.vi_normal = "block"
      $env.config.cursor_shape.vi_visual = "underscore"
      $env.PROMPT_INDICATOR = "$ "
      $env.PROMPT_INDICATOR_VI_NORMAL = "> "
      $env.PROMPT_INDICATOR_VI_INSERT = "$ "
    '';
  };
}
