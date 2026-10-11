# /clear-encrypted

按实际所需的 OpenCode V2 插件接口和数据库结构检查兼容性，不限制版本号、构建哈希或客户端与服务版本相等；这不保证所有版本都兼容。若上游报错源于失效的加密推理字段，此操作可能有帮助，但不保证解决所有错误。

服务需要 `rpc.register` 及 `session.get` / `session.interrupt` / `session.wait`；停止前先确认三种会话接口均可调用，并校验频道、位置和返回的会话身份。客户端需要 `keymap.layer` 注册本地命令，执行需要路由 `ui.router.current`、会话查询 `data.session.get`、提示 `ui.toast.show`、`client.rpc` 返回的 `clear`，以及消息刷新 `data.session.message.invalidate` / `sync`。缺少执行接口仍注册命令并在本地拒绝，不把命令发送给模型；缺少注册接口时初始化明确失败，缺少提示接口时命令以固定兼容性错误拒绝。helper 仍严格校验数据库列集合、状态、身份和备份恢复条件，不因版本较新而放宽。

在目标会话输入 `/clear-encrypted`（不接受参数）。这是本地命令，不发送提示、不生成回复、不切换模型。它捕获当前页面的会话和位置，原生停止当前会话及其附属前台子任务，等待结束，再启动独立 Bun 进程备份并事务清理；不全局停止独立或后台会话。保留聊天记录、sessionID 和可见推理文本。停止或等待失败、超时不会进入清理。

Home Manager 将源码与指向独立 Nix Bun 的 `bun` 链接打包，再将整个目录链接到 `opencode/plugins/clear-encrypted`，无需修改插件数组或继承额外环境变量。本地开发可用 `OPENCODE_CLEAR_ENCRYPTED_BUN` 覆盖运行时，仍须指向可信的 Nix Bun。安装后需要重启客户端和服务一次；本次实现不重启正在运行的服务。仅支持 Linux 本地服务端数据库；遵循服务的 `OPENCODE_DB` / XDG 路径和频道规则，并确认该文件确实被服务进程打开。远端客户端不会打开本机数据库，RPC 只传会话 ID，由目标服务校验位置。内存数据库、无法确认的路径、不兼容接口或结构均拒绝。

备份位于服务的 `$XDG_STATE_HOME/opencode/clear-encrypted/<数据库身份>/`（默认 `~/.local/state`），成功提示包含路径和计数。**备份含敏感数据**，请限制访问并自行妥善保管。逻辑删除不是安全擦除：WAL、旧备份及存储介质可能仍有副本。不支持的分叉、复制状态或数据库结构会拒绝操作。原生 compaction 加密检查点有意保留，仍可能触发上游问题。

若提示清理已提交但界面刷新失败，请重新打开会话，不要误认为数据库未修改。清理进程被取消或连接中断时，提交结果可能未知，应先核对备份和数据库状态。

## 手动恢复

先停止目标会话并等待其结束；在**数据库所属服务主机**上，用实际绝对路径构造一行 JSON 交给 helper（不通过模型或 UI 命令）：

```sh
printf '%s\n' '{"operation":"restore","dbPath":"/absolute/opencode.db","sessionID":"ses_…","directory":"/absolute/project","backupPath":"/absolute/backup.json"}' |
  ~/.config/opencode/plugins/clear-encrypted/bun ~/.config/opencode/plugins/clear-encrypted/helper.ts
```

helper 仅从 stdin 接收一个 JSON；stdout 返回 `{ "ok": true, ... }` 或 `{ "ok": false, "error": "..." }`，失败退出非零。恢复同样校验数据库身份和安全条件，不应手工覆盖数据库。恢复后重新打开会话以刷新显示。
