{
  openai = {
    options = {
      baseURL = "{env:EEHUB_API_URL}";
      apiKey = "{env:EEHUB_API_KEY}";
    };
    whitelist = [
      "gpt-5.4-pro"
      "gpt-5.5"
      "gpt-5.6-sol"
      "gpt-5.6-terra"
      "gpt-5.6-luna"
    ];
  };

  openrouter = {
    options = {
      baseURL = "{env:EEHUB_API_URL}";
      apiKey = "{env:EEHUB_API_KEY}";
    };
    whitelist = [
      "deepseek/deepseek-v4-flash"
      "deepseek/deepseek-v4-pro"
      "minimax/minimax-m3"
      "moonshotai/kimi-k2.6"
      "moonshotai/kimi-k3"
      "openai/gpt-oss-120b"
      "openai/gpt-oss-20b"
      "qwen/qwen3.7-plus"
      "qwen/qwen3.8-max"
      "x-ai/grok-4.5"
      "x-ai/grok-4.6"
      "xiaomi/mimo-v2.5"
      "z-ai/glm-5.2"
      "z-ai/glm-5.3"
    ];
    models = {
      "deepseek/deepseek-v4-pro" = {
        provider.npm = "@ai-sdk/openai-compatible";
        variants = {
          xhigh.reasoning.effort = "xhigh";
          max.reasoning.effort = "max";
        };
      };
      "deepseek/deepseek-v4-flash" = {
        provider.npm = "@ai-sdk/openai-compatible";
        variants = {
          xhigh.reasoning.effort = "xhigh";
          max.reasoning.effort = "max";
        };
      };
    };
  };

  google = {
    options = {
      baseURL = "{env:EEHUB_API_URL}";
      apiKey = "{env:EEHUB_API_KEY}";
    };
    whitelist = [
      "gemini-3.1-pro-preview"
      "gemini-3.5-flash-lite"
      "gemini-3.6-flash"
      "gemini-3.7-flash"
    ];
  };

  anthropic = {
    options = {
      baseURL = "{env:EEHUB_API_URL}";
      apiKey = "{env:EEHUB_API_KEY}";
    };
    whitelist = [
      "claude-fable-5"
      "claude-haiku-4-5"
      "claude-opus-4-6"
      "claude-opus-5"
      "claude-sonnet-4-5"
      "claude-sonnet-5"
    ];
  };
}
