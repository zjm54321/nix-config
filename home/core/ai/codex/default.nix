{ pkgs, ... }:

{
  programs.codex = {
    enable = true;
    package = pkgs.codex;
    enableMcpIntegration = true;
    settings = {
      model = "gpt-5.6-sol";
      model_provider = "eehub";
      model_reasoning_effort = "xhigh";
      model_providers.eehub = {
        name = "EEHub OpenAI Compatible";
        base_url = "http://100.100.1.2:30884/v1";
        wire_api = "responses";
        env_key = "EEHUB_API_KEY";
      };
    };
  };
}
