{ pkgs, ... }:

let
  claudeCodeWithEehub =
    (pkgs.writeShellScriptBin "claude" ''
      if [[ -z "''${EEHUB_API_URL:-}" || -z "''${EEHUB_API_KEY:-}" ]]; then
        echo "claude: EEHUB_API_URL and EEHUB_API_KEY must be set" >&2
        exit 1
      fi

      export ANTHROPIC_BASE_URL="''${EEHUB_API_URL%/v1}"
      export ANTHROPIC_AUTH_TOKEN="$EEHUB_API_KEY"
      exec ${pkgs.lib.getExe pkgs.claude-code} "$@"
    '').overrideAttrs
      {
        pname = "claude-code";
        inherit (pkgs.claude-code) version;
      };
in
{
  programs.claude-code = {
    enable = true;
    package = claudeCodeWithEehub;
    enableMcpIntegration = true;
    settings = {
      env = {
        ANTHROPIC_BETAS = "context-1m-2025-08-07";
        CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_TELEMETRY = "1";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "claude-haiku-4-5";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "claude-sonnet-4-5";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "claude-opus-5[1m]";
        ANTHROPIC_MODEL = "claude-fable-5[1m]";
        CLAUDE_CODE_SUBAGENT_MODEL = "claude-fable-5[1m]";
      };
      model = "claude-fable-5[1m]";
      hooks = { };
      extraKnownMarketplaces = {
        anthropic-agent-skills = {
          source = {
            source = "github";
            repo = "anthropics/skills";
          };
        };
      };
      language = "Chinese";
      alwaysThinkingEnabled = true;
      tui = "fullscreen";
      effortLevel = "max";
    };
  };
}
