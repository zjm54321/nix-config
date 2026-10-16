{ pkgs }:
let
  # Appended as the last system part for every model whose ID contains "gpt"
  # (core's GPT detection in packages/core/src/plugin/optimize.ts), except gpt-oss.
  text = builtins.readFile ../prompts/gpt_append.md;
  javascript = ''
    const text = ${builtins.toJSON text}.trim();

    const isGPT = (model) => {
      const id = String(model?.id ?? "").toLowerCase();
      return id.includes("gpt") && !id.includes("gpt-oss");
    };

    const append = (event) => {
      if (!isGPT(event.model)) return;
      if (event.system.some((part) => part?.type === "text" && part.text === text)) return;
      event.system.push({ type: "text", text });
    };

    export default {
      id: "gpt-system-append",
      async setup(ctx) {
        const registrations = await Promise.all(
          ["context", "compaction", "generate"].map((name) => ctx.session.hook(name, append)),
        );
        return () => Promise.all(registrations.map((registration) => registration.dispose()));
      },
    };
  '';
  packageJson = pkgs.writeText "opencode-gpt-system-append-package.json" (
    builtins.toJSON {
      name = "gpt-system-append";
      version = "0.0.0";
      type = "module";
      exports = {
        "." = "./index.js";
        "./server" = "./index.js";
      };
    }
  );
  index = pkgs.writeText "opencode-gpt-system-append-index.js" javascript;
in
pkgs.runCommand "opencode-gpt-system-append" { } ''
  install -Dm644 ${packageJson} "$out/package.json"
  install -Dm644 ${index} "$out/index.js"
''
