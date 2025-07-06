{
  inputs,
  vars,
  ...
}:
let
  port = 2222;
in
{
  networking.firewall.allowedTCPPorts = [ port ];
  # 启用 OpenSSH 守护进程。
  services.openssh = {
    enable = true;
    ports = [ port ];
    settings = {
      X11Forwarding = true;
      # root 用户用于远程部署，因此我们需要允许它
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  # SSH 密钥设置
  users.users.${vars.username}.openssh.authorizedKeys.keys =
    vars.primaryAuthorizedKeys ++ vars.secondaryAuthorizedKeys;
  users.users.root.openssh.authorizedKeys.keys = vars.primaryAuthorizedKeys;

  # 将所有已知终端的 terminfo 数据库添加到系统配置文件中。
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/config/terminfo.nix
  environment.enableAllTerminfo = true;

  # 启用 VSCode 远程连接
  imports = [ inputs.nix-vscode-server.nixosModules.default ];
  services.vscode-server.enable = true;

  services.openssh.knownHosts = {

    # https://docs.github.com/zh/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    "github/ed25519" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      hostNames = [ "github.com" ];
    };
    "github/sha2" = {
      publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
      hostNames = [ "github.com" ];
    };
    "github/rsa" = {
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      hostNames = [ "github.com" ];
    };

    # https://codeberg.org/Codeberg/org/src/branch/main/Imprint.md#user-content-ssh-fingerprints
    "codeberg/ecdsa" = {
      publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL2pDxWr18SoiDJCGZ5LmxPygTlPu+cCKSkpqkvCyQzl5xmIMeKNdfdBpfbCGDPoZQghePzFZkKJNR/v9Win3Sc=";
      hostNames = [ "codeberg.org" ];
    };
    "codeberg/rsa" = {
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8hZi7K1/2E2uBX8gwPRJAHvRAob+3Sn+y2hxiEhN0buv1igjYFTgFO2qQD8vLfU/HT/P/rqvEeTvaDfY1y/vcvQ8+YuUYyTwE2UaVU5aJv89y6PEZBYycaJCPdGIfZlLMmjilh/Sk8IWSEK6dQr+g686lu5cSWrFW60ixWpHpEVB26eRWin3lKYWSQGMwwKv4LwmW3ouqqs4Z4vsqRFqXJ/eCi3yhpT+nOjljXvZKiYTpYajqUC48IHAxTWugrKe1vXWOPxVXXMQEPsaIRc2hpK+v1LmfB7GnEGvF1UAKnEZbUuiD9PBEeD5a1MZQIzcoPWCrTxipEpuXQ5Tni4mN";
      hostNames = [ "codeberg.org" ];
    };
    "codeberg/ed25519" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
      hostNames = [ "codeberg.org" ];
    };

    # https://help.gitee.com/account/gitees-ssh-key-fingerprints
    "gitee/ed25519" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKxHSJ7084RmkJ4YdEi5tngynE8aZe2uEoVVsB/OvYN";
      hostNames = [ "gitee.com" ];
    };
    "gitee/ecdsa" = {
      publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMuEoYdx6to5oxR60IWj8uoe1aI0XfKOHWOtLqTg1tsLT1iFwXV5JmFjU46EzeMBV/6EmI1uaRI6HiEPtPtJHE=";
      hostNames = [ "gitee.com" ];
    };
    "gitee/rsa" = {
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMzG3r+88lWSDK9fyjcZmYsWGDBDmGoAasKMAmjoFloGt9HRQX2Qp4f9FY2XK/hsHYinvoh5Xytl9iaUNUWMfYR8q6VEMtOO87DgoAFcfKZHt0/nbAg9RoNTKYt6v8tPwYpr7N0JP/01nE4LFsNDnstr6H0bXSAzbKWCETLZfdPV4l2uSpRn3bU0ugoZ0aSKz5Dc/IloBfGCTvkSsxUydMRd/Chpjt6VxncDbp+Fa6pzsseK8OQzrg6Fgc5783EN3EQqZ2skqyCwExtx95BJlfx1B3luZnWfpkwNDnrZRT/Qx0OrWqyf0q6f9uQr+UG1S8qDcUn3e/9onq3rwBri8/";
      hostNames = [ "gitee.com" ];
    };
  };
}
