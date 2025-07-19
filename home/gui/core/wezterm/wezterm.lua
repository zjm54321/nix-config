local wezterm = require 'wezterm';

local config = {
  -- 初始化窗口大小
  initial_cols = 80,
  initial_rows = 24,

  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,

  -- 字体配置
  font = wezterm.font_with_fallback({
    { family = "Maple Mono NF CN", weight = "Medium", italic = false },
  }),
  harfbuzz_features = {
    "cv03", -- 替换i
    "cv61", -- 替换,;
    "cv96", -- 全角引号
    "cv97", -- 全角省略号
    "ss03", -- [info]标签
    "ss05", -- 标准\\
    "ss08", -- 双箭头和反向箭头连字
    "ss11", -- |= 连字
  },
  font_size = 16.0,

  -- 背景透明度
  window_background_opacity = 0.7,
  -- 关闭时无需确认
  window_close_confirmation = 'NeverPrompt',

  -- 默认启动时使用的 shell
  default_prog = {
    "nu"
  },

  -- 菜单启动项
  launch_menu = {
    {
      label = 'NuShell',
      args = { 'nu' },
    },
    {
      label = 'Bash',
      args = { 'bash' },
    },
  },

  -- 快捷键
  -- 默认快捷键 https://wezfurlong.org/wezterm/config/default-keys.html
  --[[
  keys = {
    -- Ctrl + p 显示启动菜单
    { key = 'p', mods = 'CTRL', action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|TABS|LAUNCH_MENU_ITEMS' } },
    -- F11 切换全屏
    { key = 'F11', mods = 'NONE', action = wezterm.action.ToggleFullScreen },
    -- Ctrl + Shift + + 字体增大
    { key = '+', mods = 'SHIFT|CTRL', action = wezterm.action.IncreaseFontSize },
    -- Ctrl + Shift + - 字体减小
    { key = '_', mods = 'SHIFT|CTRL', action = wezterm.action.DecreaseFontSize },
    -- Ctrl + t 打开新标签
    { key = 't', mods = 'CTRL', action = wezterm.action.ShowLauncher },
    -- Ctrl + w 关闭标签
    { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentTab{ confirm = false } },
    -- Ctrl + Shift + 上箭头 垂直分屏
    { key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
    -- Ctrl + Shift + 下箭头 水平分屏
    { key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
    -- Ctrl + Shift + - 缩小字体
    -- { key = "-", mods = "CTRL|SHIFT", action = wezterm.action.IncreaseFontSize },
    -- Ctrl + Shift + = 扩大字体
    -- { key = "=", mods = "CTRL|SHIFT", action = wezterm.action.DecreaseFontSize },
    -- Ctrl + Shift + 0 重置字体
    -- { key = "0", mods = "CTRL|SHIFT", action = wezterm.action.ResetFontSize },
  }
  --]]
}

-- 底部 Tab 设置
wezterm.on('update-status', function(window, pane)
  -- 右侧
  window:set_right_status(wezterm.format {
    { Foreground = { Color = 'silver' } },
    { Attribute = { Italic = true } },
    { Text = wezterm.hostname() },
  })

  --[[
  -- 左侧
  window:set_left_status(wezterm.format {
    { Foreground = { Color = 'silver' } },
    { Attribute = { Italic = true } },
    { Text = '111' },
  })
  ]]
end)

wezterm.on(-- 将 Tab 标题设置为仅数字
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local title = tab.tab_index
    return {
      { Text = ' ' .. title .. ' ' },
    }
end)


return config
