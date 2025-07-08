{
  vars,
  ...
}:
let
  defaultUser = vars.username;
  defaultPort = 2222;
  # 创建SSH主机配置的函数
  host =
    {
      hostname,
      user ? defaultUser,
      port ? defaultPort,
      identityFile ? null,
      compression ? true,
      extraOptions ? { },
    }:
    {
      inherit
        hostname
        user
        port
        compression
        ;
    }
    // (if identityFile != null then { inherit identityFile; } else { })
    // extraOptions;
in
{
  programs.ssh = {
    enable = true;

    # 使用 tailscale ip 配置主机
    matchBlocks = {
      "136kf" = host { hostname = "100.100.10.1"; };
      "e3" = host { hostname = "100.100.10.2"; };
      "e2" = host { hostname = "100.100.10.3"; };

      "sgo3" = host { hostname = "100.100.10.101"; };
      "x40" = host { hostname = "100.100.10.102"; };

      "wsl" = host { hostname = "100.100.10.201"; };
    };
  };
}
