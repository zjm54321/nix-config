{
  pkgs,
  lib,
  vars,
  ...
}:
{
  programs.zed-editor = {
    enableMcpIntegration = true;

    extensions = [
      "one-dark-pro"
      "material-icon-theme"
      "nix"
    ];

    extraPackages = with pkgs; [
      nixd
    ];

    userSettings = {
      base_keymap = "VSCode";
      load_direnv = "shell_hook";

      theme = lib.mkForce "One Dark Pro";
      icon_theme = "Material Icon Theme";
      buffer_font_family = "Maple Mono NF CN";
      buffer_font_features = {
        cv01 = true;
        cv03 = true;
        cv96 = true;
        cv97 = true;
        ss03 = true;
        ss05 = true;
        ss08 = true;
      };

      git = {
        inline_blame = {
          show_commit_summary = true;
        };
      };

      collaboration_panel = {
        button = false;
      };

      git_panel = {
        show_count_badge = true;
        tree_view = true;
        file_icons = true;
      };

      project_panel = {
        diagnostic_badges = true;
        git_status_indicator = true;
      };

      tabs = {
        show_diagnostics = "all";
        file_icons = true;
        git_status = true;
      };

      diagnostics = {
        inline = {
          enabled = true;
        };
      };

      document_symbols = "on";
      document_folding_ranges = "on";
      semantic_tokens = "combined";

      inlay_hints = {
        enabled = true;
      };

      relative_line_numbers = "enabled";

      which_key = {
        enabled = false;
      };

      cursor_blink = false;

      language_models = {
        anthropic = {
          api_url = vars.ai_api_url;
        };
        openai = {
          api_url = vars.ai_api_url + "/v1";
        };
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };

}
