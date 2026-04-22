{ secret, pkgs, ... }:
let
  aetherBaseURL = "http://100.100.10.3:8084/";
  aetherApiKey = secret.aether-api-key;

  # Fix: SubAgents always get thinkingConfig:{type:"disabled"} regardless of model.
  # Replace the conditional with the inherited parent config so Haiku/Opus SubAgents
  # get thinking enabled via the downstream per-model logic.
  # Pattern verified for claude-code 2.1.112; replace-fail ensures loud failure on
  # version bumps that re-minify the variable name.
  claudeCodePatched = pkgs.claude-code.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace cli.js \
        --replace-fail \
          'thinkingConfig:D?_.options.thinkingConfig:{type:"disabled"}' \
          'thinkingConfig:_.options.thinkingConfig'
    '';
  });
in
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = claudeCodePatched;
  };

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = aetherBaseURL;
    ANTHROPIC_AUTH_TOKEN = aetherApiKey;
  };
}
