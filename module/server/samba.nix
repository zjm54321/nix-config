{
  services.samba = {
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "ZJ";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        security = "user";
        # 仅允许 192.168.1.x 100.100.x.x、本机访问；其他全部拒绝
        "hosts allow" = "192.168.1.0/24 100.100.0.0/16 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        # 未知用户映射为来宾，实现免认证（用于 public）
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes"; # 允许匿名访问
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "smbuser";
        "force group" = "smbuser";
      };
      "private" = {
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "no"; # 禁止匿名访问
        "valid users" = "smbuser";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "smbuser";
        "force group" = "smbuser";
      };
    };
  };

  services.samba-wsdd = {
    openFirewall = true;
  };

  users.groups.smbuser = { };
  users.users.smbuser = {
    isSystemUser = true;
    group = "smbuser";
    description = "Samba user";
  };
}
