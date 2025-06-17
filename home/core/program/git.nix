{
  vars,
  ...
}:
{
  # `programs.git` 将生成配置文件：~/.config/git/config
  # 为了让 git 使用此配置文件，`~/.gitconfig` 不应存在！
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  #home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
  #  rm -f ${config.home.homeDirectory}/.gitconfig
  #'';

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = "zjm54321";
    userEmail = vars.useremail;

    extraConfig = {
      init.defaultBranch = "main"; # 初始化默认分支为 "main"
      # trim.bases = "develop,master,main"; # 用于 git-trim
      push.autoSetupRemote = true; # 推送时自动设置远程仓库
      pull.rebase = true; # 拉取时使用 rebase

      # 将 https 替换为 ssh
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
        "ssh://git@gitlab.com/" = {
          insteadOf = "https://gitlab.com/";
        };
        "ssh://git@codeberg.org/" = {
          insteadOf = "https://codeberg.org";
        };
      };
    };

    # 签名配置
    signing = {
      format = "ssh";
      key = "~/.ssh/git/signing"; # ssh签名密钥
      #  key = "EC6024351D2C32CD!"; #gpg签名密钥
      signByDefault = true; # 默认启用签名
    };

    # 一个用 Rust 编写的语法高亮分页器（2019 至今）
    #delta = {
    #  enable = true;
    #  options = {
    #    diff-so-fancy = true; # 启用 diff-so-fancy
    #    line-numbers = true; # 显示行号
    #    true-color = "always"; # 始终启用真彩色
    # features => 命名的设置组，用于组织相关设置
    # features = "";
    #  };
    #};

    # 别名配置
    aliases = {
      # 常用别名
      br = "branch"; # 分支
      co = "checkout"; # 检出
      st = "status"; # 状态
      #  ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate"; # 简化日志
      #  ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate --numstat"; # 详细日志
      cm = "commit -m"; # 提交信息
      ca = "commit -am"; # 提交所有更改
      #  dc = "diff --cached"; # 比较缓存区
      #
      #  amend = "commit --amend -m"; # 修改提交信息
      #  unstage = "reset HEAD --"; # 取消暂存文件
      #  merged = "branch --merged"; # 列出已合并（到 HEAD）的分支
      #  unmerged = "branch --no-merged"; # 列出未合并（到 HEAD）的分支
      #  nonexist = "remote prune origin --dry-run"; # 列出不存在的远程分支
      #
      #  # 删除已合并的分支（排除 master、dev 和 staging）
      #  #  `!` 表示这是一个 shell 脚本，而不是 git 子命令
      #  delmerged = ''! git branch --merged | egrep -v "(^\*|main|master|dev|staging)" | xargs git branch -d'';
      #  # 删除不存在的远程分支
      #  delnonexist = "remote prune origin";
      #
      #  # 子模块相关别名
      #  update = "submodule update --init --recursive"; # 更新子模块
      #  foreach = "submodule foreach"; # 遍历子模块
    };
  };
}
