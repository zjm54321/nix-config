{ pkgs, ... }:

let
  codexWithEehub =
    (pkgs.writeShellScriptBin "codex" ''
      if [[ -z "''${EEHUB_API_URL:-}" || -z "''${EEHUB_API_KEY:-}" ]]; then
        echo "codex: EEHUB_API_URL and EEHUB_API_KEY must be set" >&2
        exit 1
      fi

      exec ${pkgs.lib.getExe pkgs.codex} \
        -c "model_providers.eehub.base_url=\"$EEHUB_API_URL\"" \
        "$@"
    '').overrideAttrs {
      pname = "codex";
      inherit (pkgs.codex) version;
    };
in
{
  programs.codex = {
    enable = true;
    package = codexWithEehub;
    enableMcpIntegration = true;
    settings = {
      model = "gpt-5.6-sol";
      model_provider = "eehub";
      model_reasoning_effort = "xhigh";
      model_providers.eehub = {
        name = "eehub";
        wire_api = "responses";
        env_key = "EEHUB_API_KEY";
      };
    };
  };
}
