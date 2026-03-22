{
  secret,
  ...
}:
let
  githubMcpToken = builtins.elemAt (builtins.match "github.com=(.*)" secret.nix-github-access-tokens) 0;
in
{
  mcp-servers.programs = {
    github = {
      enable = true;
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = githubMcpToken;
      };
    };

    nixos.enable = true;

    context7 = {
      enable = true;
      env = {
        CONTEXT7_API_KEY = secret.context7-api-key;
      };
    };
  };
}
