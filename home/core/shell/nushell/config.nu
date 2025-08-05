$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 5_000_000

$env.config.show_banner   = false

$env.config.edit_mode     = "vi"
# 类似 vim 的按键样式
$env.config.cursor_shape.vi_insert = "line"      
$env.config.cursor_shape.vi_normal = "block"  

# vim模式识别符 [todo]将其迁移到starship
$env.PROMPT_INDICATOR = "$ "
$env.PROMPT_INDICATOR_VI_INSERT = "$ "

# 解决 wizterm 缓冲区问题
$env.config.shell_integration = {
  osc133:false
}

#添加starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# 添加自动补全
source auto-complete/git.nu

