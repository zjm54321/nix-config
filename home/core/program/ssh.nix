{
  vars,
  lib,
  pkgs,
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
    enableDefaultConfig = false;
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

      "home-server" = host { hostname = "100.100.1.1"; };
    };
  };

  home.packages = [ pkgs.waypipe ];

  home.shellAliases = {
    wsh = "waypipe ssh";
    xsh = "ssh -Y";
  };

  home.file = {
    # home-manager wrongly thinks it doesn't manage (and thus shouldn't clobber) this file due to the activation script
    ".ssh/config".force = true;
  };

  home.activation = {
    # https://github.com/nix-community/home-manager/issues/322
    fixSshPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run install -d -m 0700 "$HOME/.ssh"
      if [ -L "$HOME/.ssh/config" ]; then
        src="$(readlink -f "$HOME/.ssh/config")"
        run rm -f "$HOME/.ssh/config"
        run install -m 0600 "$src" "$HOME/.ssh/config"
      fi
    '';
  };
}
