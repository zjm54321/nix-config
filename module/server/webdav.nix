{
  vars,
  ...
}:
{
  services.webdav = {
    settings = {
      address = "0.0.0.0";
      port = 8888;
      permissions = "CRUD";
      users = [
        {
          username = vars.username;
          password = "nix"; # [fixme] 请修改密码
        }
      ];
    };
  };
}
