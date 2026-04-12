{ vars, secret, ... }:
{
  programs.aichat = {
    enable = true;
    settings = {
      model = "aether:gpt-5.3-codex";
      clients = [
        {
          type = "openai-compatible";
          name = "aether";
          api_base = "${vars.ai_api_url}/v1";
          api_key = secret.aether-api-key;
          models = [
            { name = "claude-haiku-4-5-20251001"; }
            { name = "glm-5"; }
            { name = "gpt-5-mini"; }
            { name = "gpt-5.4"; }
            { name = "gpt-5.3-codex"; }
          ];
        }
      ];
    };
  };
}
