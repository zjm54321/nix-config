/*
  添加了记忆倍速和修改键位的 wiliwili
  https://github.com/xfangfang/wiliwili/issues/119
  https://github.com/xfangfang/wiliwili/discussions/527
*/
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.programs.wiliwili.enable = mkEnableOption "启用wiliwili";

  config = mkIf config.programs.wiliwili.enable {
    home.packages = [
      (pkgs.wiliwili.overrideAttrs (
        finalAttrs: previousAttrs: {
          postPatch =
            (previousAttrs.postPatch or "")
            + ''
              sed -i 's/GLFW_KEY_UP/GLFW_KEY_W/g' ./library/borealis/library/lib/platforms/glfw/glfw_input.cpp
              sed -i 's/GLFW_KEY_DOWN/GLFW_KEY_S/g' ./library/borealis/library/lib/platforms/glfw/glfw_input.cpp
              sed -i 's/GLFW_KEY_LEFT/GLFW_KEY_A/g' ./library/borealis/library/lib/platforms/glfw/glfw_input.cpp
              sed -i 's/GLFW_KEY_RIGHT/GLFW_KEY_D/g' ./library/borealis/library/lib/platforms/glfw/glfw_input.cpp
              sed -i 's/GLFW_KEY_L/GLFW_KEY_LEFT/g' ./library/borealis/library/lib/platforms/glfw/glfw_input.cpp
              sed -i 's/GLFW_KEY_R/GLFW_KEY_RIGHT/g' ./library/borealis/library/lib/platforms/glfw/glfw_input.cpp
              sed -i 's/mpvSetOptionString(mpv, "reset-on-next-file", "speed,pause")/mpvSetOptionString(mpv, "reset-on-next-file", "pause")/g' ./wiliwili/source/view/mpv_core.cpp
            '';
        }
      ))
    ];

    # 只有当配置文件不存在时才创建初始配置
    home.activation.wiliwiliConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            config_file="$HOME/.config/wiliwili/wiliwili_config.json"
            if [ ! -f "$config_file" ]; then
              mkdir -p "$(dirname "$config_file")"
              cat > "$config_file" << 'EOF'
      {
        "setting": {
          "app_swap_abxy": true,
          "danmaku": true,
          "danmaku_filter_advanced": true,
          "danmaku_filter_bottom": true,
          "danmaku_filter_color": true,
          "danmaku_filter_level": 6,
          "danmaku_filter_scroll": true,
          "danmaku_filter_top": true,
          "danmaku_render_quality": 100,
          "danmaku_smart_mask": true,
          "danmaku_style_alpha": 80,
          "danmaku_style_area": 25,
          "danmaku_style_fontsize": 30,
          "danmaku_style_line_height": 120,
          "danmaku_style_speed": 100,
          "file_format": 4048,
          "fullscreen": true,
          "keymap": "keyboard",
          "player_default_speed": 200,
          "player_highlight_bar": false,
          "player_hwdec": true,
          "player_hwdec_custom": "vaapi-copy",
          "player_inmemory_cache": 20,
          "player_low_quality": true,
          "player_osd_tv_mode": true,
          "player_strategy": 3,
          "player_volume": 100,
          "search_tv_mode": false,
          "video_codec": 7,
          "video_quality": 80
        }
      }
      EOF
            fi
    '';
  };
}
