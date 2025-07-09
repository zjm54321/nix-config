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
      extraOptions ? { },
    }:
    {
      inherit
        hostname
        user
        port
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
      "localhost" = host { hostname = "localhost"; };

      "136kf" = host {
        # 目前是windows设备
        hostname = "100.100.10.1";
        user = vars.useremail;
      };
      "e3" = host { hostname = "100.100.10.2"; };
      "e2" = host { hostname = "100.100.10.3"; };

      "sgo3" = host { hostname = "100.100.10.101"; };
      "x40" = host { hostname = "100.100.10.102"; };

      "wsl" = host { hostname = "100.100.10.201"; };
    };
  };
}
