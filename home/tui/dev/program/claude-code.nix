{ secret, pkgs, ... }:
let
  aetherBaseURL = "http://100.100.10.3:8084/";
  aetherApiKey = secret.aether-api-key;
in
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = aetherBaseURL;
    ANTHROPIC_AUTH_TOKEN = aetherApiKey;
  };
}
