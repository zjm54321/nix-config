# nix-config

这是本机的系统 Flake：WSL2 上的 NixOS，主机为 `nixosConfigurations.136kf`，分支 `wsl`，远程仓库 <https://github.com/zjm54321/nix-config>。

## 目录结构

- `flake.nix` / `flake.lock`：输入与输出。`module/ai/skill` 是本地 `path:` 子 Flake（输入名 `skills-catalog`），管理 agent skills。
- `host/`：NixOS 主机配置。`module/`：共享的 NixOS 与 Home Manager 模块。`home/`：Home Manager 配置。
- `home/core/ai/agent/opencode/`：OpenCode V2 配置（`opencode.json`、`oh-my-opencode-slim.json`、插件、providers，以及全局 `AGENTS.md` 模板）。`opencode1/` 是 V1 配置，部署到 `~/.config/oc1`。
- `/etc/nixos/src` 是已部署系统生成的只读快照。只改这个仓库，不要改快照。

## 工作流程

使用 `Justfile` 里的 recipe，不要手工拼命令重做：

- `just switch`：构建并激活（`nixos-rebuild switch --flake path:.#$(hostname) --sudo`）。
- `just fmt` / `just check` / `just health`：格式化、`nix flake check`、检查激活后的系统（`systemctl is-system-running` 必须是 `running`）。
- `just update`：更新全部 flake 输入。只升级个别输入时，运行 `nix flake update --flake path:. <input>...`。
- `just push`：用 GitHub CLI 凭据推送。只有用户要求时才推送。

**系统更新请求：** 用户要求更新系统、部署并提交时（例如“更新系统然后部署提交”），运行 `just system-update`。它要求工作区干净，依次执行 update → fmt → check → switch → health → commit → cleanup（保留 3 个系统 generation，然后垃圾回收）。除非用户明确要求别的流程，否则直接使用这个聚合 recipe，不要拆开执行。它不会推送。

修改配置时：先改文件，再运行 `just fmt switch health`，最后用 conventional commit 格式提交。运行 `just system-update` 前，先 stash 或提交无关改动，因为它的提交步骤会执行 `git add --all`。

## 约定

- 插件和工具固定到明确版本；有意不升级时写明原因。
- 删除功能时，一并删除不再使用的绑定和输入，并刷新受影响输入的 `flake.lock`。
