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
        name = "eehub";
        base_url = "{env:EEHUB_API_URL}";
        wire_api = "responses";
        env_key = "EEHUB_API_KEY";
      };
    };
  };
}
