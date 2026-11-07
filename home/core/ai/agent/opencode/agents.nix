let
  gemini = {
    id = "google/gemini-4-argon";
    variant = "high";
  };
  sonnet = {
    id = "anthropic/claude-sonnet-5-5";
    variant = "high";
  };
  luna = {
    id = "openai/gpt-6-luna";
    variant = "xhigh";
  };
  researchPermission = {
    edit = "deny";
    bash = "allow";
    webfetch = "allow";
    websearch = "allow";
  };
  offlinePermission = researchPermission // {
    bash = "deny";
    webfetch = "deny";
    websearch = "deny";
  };
  promptNames = [
    "brainstorm_append"
    "scribe_append"
    "ideator"
    "scout"
    "red-team"
    "doc-researcher"
    "drafter"
    "fact-checker"
    "typesetter"
  ];
in
{
  # Requires OMO 3.0.7 (opencode-qol v2.2.5-qol.2).
  programs.opencode-qol.slim.settings = {
    "$schema" = "https://unpkg.com/oh-my-opencode-slim@3.0.7/oh-my-opencode-slim.schema.json";
    agents = {
      orchestrator.permission.task = {
        # Keep stock routing: do not set orchestrator.subagents, which cannot
        # include marketplace specialists such as documenter and validator.
        "*" = "deny";
        explorer = "allow";
        oracle = "allow";
        fixer = "allow";
        designer = "allow";
        council = "allow";
        documenter = "allow";
        validator = "allow";
        # The orchestrator dispatches council seats before council synthesis.
        councillor-alpha = "allow";
        councillor-beta = "allow";
        councillor-gamma = "allow";
      };

      brainstorm = {
        primary = true;
        subagents = [
          "ideator"
          "scout"
          "red-team"
        ];
        inheritModelFrom = "orchestrator";
        description = "头脑风暴与调研：澄清问题、发散、查证、挑战，收敛成可行动的建议";
        skills = [
          "grill-me"
          "grilling"
          "deanchor"
        ];
        mcps = [ ];
      };

      scribe = {
        primary = true;
        subagents = [
          "doc-researcher"
          "drafter"
          "fact-checker"
          "typesetter"
        ];
        inheritModelFrom = "orchestrator";
        description = "文书主笔：报告、论文、方案、邮件、PPT、LaTeX，中英文";
        skills = [
          "shuorenhua"
          "humanizer-zh"
          "humanizer"
          "writing-clearly-and-concisely"
          "deanchor"
          "output-presentation"
        ];
        mcps = [ ];
      };

      ideator = {
        description = "发散：从多个角度产出候选想法，写清怎么起作用和前提；不评判、不调研";
        model = [
          gemini
          sonnet
        ];
        permission = offlinePermission;
        mcps = [ ];
        skills = [ ];
      };

      scout = {
        description = "调研：查先例、数据、论文和产品，交带链接的支持和反对证据；不下结论";
        model = [
          luna
          gemini
        ];
        permission = researchPermission;
        mcps = [
          "context7"
          "gh_grep"
        ];
        skills = [ "customer-research" ];
      };

      red-team = {
        description = "挑战：最强复述、最有力反驳、失败信号和事前验尸；不迎合";
        model = [
          {
            id = "openai/gpt-6-astra";
            variant = "max";
          }
          gemini
        ];
        permission = offlinePermission;
        mcps = [ ];
        skills = [ ];
      };

      doc-researcher = {
        description = "资料：收集带来源的事实、数字和引文清单，标出缺口；不写正文";
        model = [
          luna
          gemini
        ];
        permission = researchPermission;
        mcps = [
          "context7"
          "gh_grep"
        ];
        skills = [ ];
      };

      drafter = {
        description = "执笔：按大纲和资料写中英文稿，标出缺证据处，中文去 AI 味";
        model = [
          {
            id = "anthropic/claude-opus-5-5";
            variant = "high";
          }
          sonnet
        ];
        permission = offlinePermission // {
          edit = "allow";
        };
        mcps = [ ];
        skills = [
          "shuorenhua"
          "humanizer-zh"
          "humanizer"
          "writing-clearly-and-concisely"
        ];
      };

      fact-checker = {
        description = "核查：逐条核对事实、数字、引文和参考文献，只报问题不改稿";
        model = [
          {
            id = "openai/gpt-6-astra";
            variant = "high";
          }
          gemini
        ];
        permission = researchPermission;
        mcps = [ "context7" ];
        skills = [ ];
      };

      typesetter = {
        description = "排版：生成 docx/pptx/PDF/LaTeX，编译并渲染页面逐页自查";
        model = [
          {
            id = "openai/gpt-6.1-sol";
            variant = "high";
          }
          sonnet
        ];
        permission = offlinePermission // {
          edit = "allow";
          bash = "allow";
        };
        mcps = [ ];
        skills = [ "doc-toolchain" ];
      };
    };
  };

  xdg.configFile = builtins.listToAttrs (
    map (name: {
      name = "opencode/oh-my-opencode-slim/${name}.md";
      value.source = ./prompts + "/${name}.md";
    }) promptNames
  );
}
