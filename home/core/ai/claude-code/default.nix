{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
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
      enabledPlugins = {
        "document-skills@anthropic-agent-skills" = true;
      };
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
      effortLevel = "xhigh";
    };
  };
}
