{
  config,
  lib,
  pkgs,
  ...
}:

let
  codexConfigDir =
    if config.home.preferXdgDirectories then
      "${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/codex"
    else
      ".codex";
  codexConfigTarget = "${codexConfigDir}/config.toml";
  codexRuntimeHome =
    if config.home.preferXdgDirectories then "${config.xdg.configHome}/codex" else "${config.home.homeDirectory}/.codex";
  codexRuntimeConfig = "${codexRuntimeHome}/config.toml";
  codexStateDir = "${codexRuntimeHome}/.hm-config-state";
  codexConfigBaseline = config.home.file."${codexConfigTarget}".source;
  writableConfigHelper = pkgs.writeShellScriptBin "codex-writable-config" ''
    exec ${lib.getExe pkgs.python3} ${./writable-config.py} "$@"
  '';
  codexWithEehub =
    (pkgs.writeShellScriptBin "codex" ''
      if [[ -z "''${EEHUB_API_URL:-}" || -z "''${EEHUB_API_KEY:-}" ]]; then
        echo "codex: EEHUB_API_URL and EEHUB_API_KEY must be set" >&2
        exit 1
      fi

      exec ${pkgs.lib.getExe pkgs.codex} \
        -c "model_providers.eehub.base_url=\"$EEHUB_API_URL\"" \
        "$@"
    '').overrideAttrs
      {
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

  home.file."${codexConfigTarget}".target = "${codexConfigTarget}.hm-source";

  home.activation.backupCodexManagedConfig = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    run ${lib.getExe writableConfigHelper} backup-legacy \
      --target ${lib.escapeShellArg codexRuntimeConfig} \
      --state-dir ${lib.escapeShellArg codexStateDir}
  '';

  home.activation.seedCodexWritableConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${lib.getExe writableConfigHelper} seed \
      --baseline ${lib.escapeShellArg (toString codexConfigBaseline)} \
      --target ${lib.escapeShellArg codexRuntimeConfig} \
      --state-dir ${lib.escapeShellArg codexStateDir}
  '';
}
