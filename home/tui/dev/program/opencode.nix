{
  lib,
  pkgs,
  secret,
  ...
}:
let
  aetherBaseURL = "http://100.100.10.3:8084/v1";
  aetherApiKey = secret.aether-api-key;

  mkAnthropicModel =
    name:
    {
      inputCost ? 1.0,
      outputCost ? 5.0,
      context ? 200000,
      output ? 64000,
    }:
    {
      inherit name;
      cost = {
        input = inputCost;
        output = outputCost;
      };
      limit = {
        inherit context output;
      };
      modalities = {
        input = [
          "text"
          "image"
          "pdf"
        ];
        output = [ "text" ];
      };
      variants = {
        low.thinkingConfig.thinkingBudget = 4096;
        medium.thinkingConfig.thinkingBudget = 8192;
        high.thinkingConfig.thinkingBudget = 16384;
        max.thinkingConfig.thinkingBudget = 32768;
      };
    };

  mkOpenAIModel =
    name:
    {
      inputCost ? 1.75,
      outputCost ? 14.0,
      context ? 400000,
      output ? 128000,
      modalities ? [
        "text"
      ],
      extraVariants ? { },
    }:
    {
      inherit name;
      cost = {
        input = inputCost;
        output = outputCost;
      };
      limit = {
        inherit context output;
      };
      modalities = {
        input = modalities;
        output = [ "text" ];
      };
      variants = {
        low.reasoningEffort = "low";
        medium.reasoningEffort = "medium";
        high.reasoningEffort = "high";
      }
      // extraVariants;
    };
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      lsp = {
        marksman = {
          command = [
            "${lib.getExe pkgs.marksman}"
            "server"
          ];
          extensions = [
            ".md"
            ".markdown"
          ];
        };
      };

      plugin = [ "oh-my-openagent@latest" ];

      provider = {
        anthropic = {
          name = "Anthropic";
          options = {
            baseURL = aetherBaseURL;
            apiKey = aetherApiKey;
          };
          models = {
            "claude-haiku-4-5-20251001" = mkAnthropicModel "Claude Haiku 4.5" {
              inputCost = 1.0;
              outputCost = 5.0;
            };
            "claude-opus-4-6" = mkAnthropicModel "Claude Opus 4.6" {
              inputCost = 5.0;
              outputCost = 25.0;
            };
            "claude-sonnet-4-6" = mkAnthropicModel "Claude Sonnet 4.6" {
              inputCost = 3.0;
              outputCost = 15.0;
            };
          };
        };

        google = {
          name = "Google";
          options = {
            baseURL = "http://100.100.10.3:8084/v1beta";
            apiKey = aetherApiKey;
          };
          models = {
            "gemini-3-pro" = {
              name = "Gemini 3 Pro";
              cost = {
                input = 2.0;
                output = 12.0;
              };
              limit = {
                context = 1048576;
                output = 65536;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                  "pdf"
                ];
                output = [ "text" ];
              };
              variants = {
                minimal.thinkingLevel = "minimal";
                low.thinkingLevel = "low";
                medium.thinkingLevel = "medium";
                high.thinkingLevel = "high";
              };
            };
          };
        };

        zhipu = {
          name = "Zhipu AI";
          api = "openai";
          options = {
            baseURL = aetherBaseURL;
            apiKey = aetherApiKey;
          };
          models = {
            "glm-4.6" = {
              name = "GLM-4.6";
              cost = {
                input = 0.6;
                output = 2.2;
              };
              limit = {
                context = 131072;
                output = 16384;
              };
              modalities = {
                input = [ "text" ];
                output = [ "text" ];
              };
              variants = {
                low.reasoningEffort = "low";
                medium.reasoningEffort = "medium";
                high.reasoningEffort = "high";
              };
            };
            "glm-5" = {
              name = "GLM-5";
              cost = {
                input = 1.0;
                output = 3.2;
              };
              limit = {
                context = 262144;
                output = 32768;
              };
              modalities = {
                input = [ "text" ];
                output = [ "text" ];
              };
              variants = {
                low.reasoningEffort = "low";
                medium.reasoningEffort = "medium";
                high.reasoningEffort = "high";
              };
            };
          };
        };

        openai = {
          name = "OpenAI";
          options = {
            baseURL = aetherBaseURL;
            apiKey = aetherApiKey;
          };
          models = {
            "gpt-5.2" = mkOpenAIModel "GPT-5.2" {
              modalities = [
                "text"
                "image"
                "pdf"
              ];
              extraVariants = {
                xhigh = {
                  reasoningEffort = "high";
                  verbosity = "high";
                };
              };
            };
            "gpt-5.2-codex" = mkOpenAIModel "GPT-5.2 Codex" {
              extraVariants = {
                xhigh = {
                  reasoningEffort = "high";
                  verbosity = "high";
                };
              };
            };
            "gpt-5.3-codex" = mkOpenAIModel "GPT-5.3 Codex" {
              extraVariants = {
                xhigh = {
                  reasoningEffort = "high";
                  verbosity = "high";
                };
              };
            };
            "gpt-5.3-codex-spark" = mkOpenAIModel "GPT-5.3 Codex Spark" {
              output = 64000;
              extraVariants = {
                minimal.reasoningEffort = "low";
              };
            };
          };
        };
      };
    };
  };

  # oh-my-opencode 插件配置
  xdg.configFile."opencode/oh-my-opencode.jsonc".text = builtins.toJSON {
    "$schema" =
      "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";

    runtime_fallback = {
      enabled = true;
      retry_on_errors = [
        400
        429
        500
        503
        529
      ];
      max_fallback_attempts = 3;
      cooldown_seconds = 60;
      timeout_seconds = 60;
      notify_on_fallback = true;
    };

    agents = {
      sisyphus = {
        model = "anthropic/claude-opus-4-6";
        temperature = 0.1;
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
          "zhipu/glm-5"
          "openai/gpt-5.3-codex"
          "google/gemini-3-pro"
        ];
      };
      atlas = {
        model = "openai/gpt-5.2";
        temperature = 0.1;
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
          "zhipu/glm-5"
          "google/gemini-3-pro"
        ];
      };
      prometheus = {
        model = "anthropic/claude-opus-4-6";
        temperature = 0.1;
        fallback_models = [
          "zhipu/glm-5"
          "openai/gpt-5.2"
        ];
      };
      metis = {
        model = "anthropic/claude-opus-4-6";
        temperature = 0.3;
        variant = "max";
        fallback_models = [
          "zhipu/glm-5"
          "openai/gpt-5.2"
        ];
      };
      momus = {
        model = "openai/gpt-5.2";
        temperature = 0.1;
        variant = "medium";
        fallback_models = [
          "anthropic/claude-opus-4-6"
          "google/gemini-3-pro"
        ];
      };
      hephaestus = {
        model = "openai/gpt-5.3-codex";
        temperature = 0.1;
        variant = "medium";
        fallback_models = [ "openai/gpt-5.2-codex" ];
      };
      oracle = {
        model = "openai/gpt-5.2";
        temperature = 0.1;
        variant = "high";
        fallback_models = [
          "google/gemini-3-pro"
          "anthropic/claude-opus-4-6"
        ];
      };
      librarian = {
        model = "zhipu/glm-4.6";
        fallback_models = [
          "zhipu/glm-5"
          "openai/gpt-5.3-codex-spark"
          "google/gemini-3-pro"
        ];
      };
      explore = {
        model = "openai/gpt-5.3-codex-spark";
        fallback_models = [
          "anthropic/claude-haiku-4-5-20251001"
          "zhipu/glm-4.6"
          "openai/gpt-5.2-codex"
        ];
      };
      multimodal-looker = {
        model = "google/gemini-3-pro";
        fallback_models = [
          "openai/gpt-5.2"
          "anthropic/claude-opus-4-6"
        ];
      };
    };

    categories = {
      quick = {
        model = "openai/gpt-5.3-codex-spark";
        temperature = 0.1;
      };
      deep = {
        model = "openai/gpt-5.3-codex";
        variant = "medium";
        temperature = 0.1;
      };
      ultrabrain = {
        model = "openai/gpt-5.3-codex";
        variant = "xhigh";
        temperature = 0.1;
      };
      visual-engineering = {
        model = "google/gemini-3-pro";
        variant = "high";
        temperature = 0.1;
      };
      writing = {
        model = "google/gemini-3-pro";
        variant = "medium";
        temperature = 0.2;
      };
      artistry = {
        model = "google/gemini-3-pro";
        variant = "high";
        temperature = 0.2;
      };
      unspecified-low = {
        model = "anthropic/claude-sonnet-4-6";
        temperature = 0.1;
      };
      unspecified-high = {
        model = "anthropic/claude-opus-4-6";
        variant = "max";
        temperature = 0.1;
      };
    };
  };
}
