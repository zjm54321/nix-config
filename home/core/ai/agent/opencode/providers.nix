{
  openai = {
    options = {
      baseURL = "{env:EEHUB_API_URL}";
      apiKey = "{env:EEHUB_API_KEY}";
    };
    whitelist = [
      "gpt-6-astra"
      "gpt-5.6-luna"
      "gpt-5.6-sol"
      "gpt-5.6-terra"
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
      "moonshotai/kimi-k3"
      "openai/gpt-oss-20b"
      "z-ai/glm-5.2"
      "z-ai/glm-5.3"
      "z-ai/glm-5.3-flash"
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
      "gemini-3.7-flash"
      "gemini-3.8-flash"
    ];
  };

  anthropic = {
    options = {
      baseURL = "{env:EEHUB_API_URL}";
      apiKey = "{env:EEHUB_API_KEY}";
    };
    whitelist = [
      "claude-haiku-4-5"
      "claude-sonnet-4-5"
    ];
  };
}
