import { definition, id, reasons, safeReason, SUPPORTED_VERSION, type ClearResult } from "./rpc"

type Location = { directory: string; workspaceID?: string }
export interface TuiContext {
  app: { version: string }
  keymap: { layer(factory: () => { commands: { id: string; title: string; slash: { name: string; arguments: true }; run(input?: string): Promise<void> }[] }): void }
  ui: {
    router: { current(): { type: string; sessionID?: string } }
    toast: { show(input: { message: string; variant: "info" | "success" | "error"; sessionID?: string }): void }
  }
  data: { session: {
    get(id: string): { location: Location } | undefined
    message: { invalidate(id: string): void; sync(id: string): Promise<void> }
  } }
  client: { rpc(schema: typeof definition): { clear(input: { sessionID: string }, options: { location: Location }): Promise<unknown> } }
}

export default {
  id,
  setup(ctx: TuiContext) {
    const pending = new Set<string>()
    ctx.keymap.layer(() => ({
      // ALWAYS registered: disabling it could let typed slash text reach the model.
      commands: [{
        id,
        title: "清理当前会话的加密推理上下文",
        slash: { name: id, arguments: true },
        async run(input?: string) {
          const route = ctx.ui.router.current()
          const sessionID = route.type === "session" ? route.sessionID : undefined
          const stored = sessionID ? ctx.data.session.get(sessionID)?.location : undefined
          const location = stored ? { ...stored } : undefined
          const toast = (message: string, variant: "info" | "success" | "error") =>
            ctx.ui.toast.show({ message, variant, ...(sessionID ? { sessionID } : {}) })
          if (input?.trim()) return toast("此命令不接受参数", "error")
          if (!sessionID) return toast("当前页面没有会话", "error")
          if (!location) return toast(`清理未完成：${reasons.location}`, "error")
          if (ctx.app.version !== SUPPORTED_VERSION) return toast(`清理未完成：${reasons.version}`, "error")
          if (pending.has(sessionID)) return toast(`清理未完成：${reasons.busy}`, "error")
          pending.add(sessionID)
          toast("正在停止当前会话并备份加密上下文…", "info")
          try {
            const committed = await ctx.client.rpc(definition).clear({ sessionID }, { location }) as ClearResult
            toast(committed.removedFields === 0
              ? "当前会话没有可清理的加密推理字段"
              : `已清理加密推理上下文，聊天记录已保留。\n消息 ${committed.changedMessages}，事件 ${committed.changedEvents}，字段 ${committed.removedFields}\n备份：${committed.backupPath ?? "未返回路径"}`, "success")
            // Refresh is best-effort: a stalled sync must not hide the confirmed
            // commit/backup or keep this command pending. Capture this result/session.
            void Promise.resolve().then(async () => {
              ctx.data.session.message.invalidate(sessionID)
              await ctx.data.session.message.sync(sessionID)
            }).catch(() => {
              toast(`${reasons.refresh}${committed.backupPath ? `\n备份：${committed.backupPath}` : ""}`, "error")
            })
          } catch (error) {
            toast(`清理未完成：${safeReason(error)}`, "error")
          } finally {
            pending.delete(sessionID)
          }
        },
      }],
    }))
  },
}
