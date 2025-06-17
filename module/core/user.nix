{
  vars,
  pkgs,
  ...
}:
{
  # 定义用户账户
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.userfullname;
    home = "/home/${vars.username}";
    shell = pkgs.nushell; # 默认使用 Nushell

    # 由 `mkpasswd -m scrypt` 生成
    # 当根目录使用 tmpfs 时，我们必须使用 initialHashedPassword
    inherit (vars) initialHashedPassword;

    extraGroups = [
      vars.username
      "users"
      "networkmanager"
      "wheel"
      "docker"
      "wireshark"
      "adbusers"
      "libvirtd"
    ];
  };
  # 给予此列表中的用户通过以下方式指定额外替代源的权限：
  #    1. `flake.nix` 中的 `nixConfig.substituers`
  #    2. 命令行参数 `--options substituers http://xxx`
  nix.settings.trusted-users = [ vars.username ];

  # 不允许在配置之外修改用户
  users.mutableUsers = false;

  users.groups = {
    "${vars.username}" = { };
    docker = { };
    wireshark = { };
    # 用于 Android 平台工具的 udev 规则
    adbusers = { };
    dialout = { };
    # 用于 openocd（嵌入式系统开发）
    plugdev = { };
    # 杂项
    uinput = { };
  };

  # root 的 ssh 密钥主要用于远程部署
  users.users.root = {
    inherit (vars) initialHashedPassword;
  };
}
