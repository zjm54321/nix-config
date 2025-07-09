# just 是一个命令运行器，Justfile 与 Makefile 很相似，但更简单。

# 使用 nushell 执行 shell 命令
# 要使用这个 justfile，你需要进入一个安装了 just 和 nushell 的 shell：
# 
#   nix shell nixpkgs#just nixpkgs#nushell
set shell := ["nu", "-c"]

utils_nu := absolute_path("utils.nu")

############################################################################
#
#  通用命令（适用于所有机器）
#
############################################################################

# 列出所有 just 命令
default:
    @just --list

# 全新安装
[group('nix')]
install config:
  nixos-install --flake .#{{config}}

# 部署系统配置
[group('nix')]
deploy:
  nixos-rebuild switch --flake .

# 远程部署系统配置
[group('nix')]
remote config target_host build_host:
  nixos-rebuild switch --flake .#{{config}} --target-host {{target_host}} --build-host {{build_host}}


# 更新所有 flake 输入
[group('nix')]
up:
  nix flake update

# 更新特定输入
# 用法：just upp nixpkgs
[group('nix')]
upp input:
  nix flake update {{input}}

# 列出系统配置文件的所有代数
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# 使用 flake 打开 nix shell
[group('nix')]
repl:
  nix repl -f flake:nixpkgs

# 删除所有超过 7 天的代数
[group('nix')]
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# 垃圾收集所有未使用的 nix store 条目
[group('nix')]
gc:
  # 垃圾收集所有未使用的 nix store 条目（系统范围）
  sudo nix-collect-garbage --delete-older-than 7d
  # 垃圾收集所有未使用的 nix store 条目（用户 - home-manager）
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d

# 进入一个包含此 flake 所有必要工具的 shell 会话
[group('nix')]
shell:
  nix shell nixpkgs#git nixpkgs#neovim nixpkgs#colmena

# 格式化此仓库中的 nix 文件
[group('nix')]
fmt:
  nix fmt

# 显示 nix store 中的所有自动 gc 根
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/

# 验证所有 store 条目
# 如果 nix store 对象被意外修改，Nix Store 可能包含损坏的条目。
# 此命令将验证所有 store 条目，
# 我们需要通过 `sudo nix store delete <store-path-1> <store-path-2> ...` 手动修复损坏的条目
[group('nix')]
verify-store:
  nix store verify --all

# 修复 Nix Store 对象
[group('nix')]
repair-store *paths:
  nix store repair {{paths}}

# =================================================
#
# 其他有用的命令
#
# =================================================

[group('common')]
path:
   $env.PATH | split row ":"

[group('common')]
trace-access app *args:
  strace -f -t -e trace=file {{app}} {{args}} | complete | $in.stderr | lines | find -v -r "(/nix/store|/newroot|/proc)" | parse --regex '"(/.+)"' | sort | uniq

[group('common')]
penvof pid:
  sudo cat $"/proc/($pid)/environ" | tr '\0' '\n'

# 移除所有 reflog 条目并清理不可达对象
[group('git')]
ggc:
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now

# 修改最后一次提交而不更改提交消息
[group('git')]
game:
  git commit --amend -a --no-edit

[group('services')]
list-inactive:
  systemctl list-units -all --state=inactive

[group('services')]
list-failed:
  systemctl list-units -all --state=failed

[group('services')]
list-systemd:
  systemctl list-units systemd-*
