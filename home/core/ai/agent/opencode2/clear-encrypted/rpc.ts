export const SUPPORTED_VERSION = "2.0.24+de2cacd"
export const id = "clear-encrypted"

export type ClearResult = {
  ok: true
  changedMessages: number
  changedEvents: number
  removedFields: number
  backupPath?: string
}

// Portable JSON schema: no SDK/runtime dependencies and no caller-selected paths.
export const definition = {
  id,
  methods: {
    clear: {
      input: {
        type: "object",
        properties: { sessionID: { type: "string", minLength: 1 } },
        required: ["sessionID"],
        additionalProperties: false,
      },
      output: {
        type: "object",
        properties: {
          ok: { const: true },
          changedMessages: { type: "integer", minimum: 0 },
          changedEvents: { type: "integer", minimum: 0 },
          removedFields: { type: "integer", minimum: 0 },
          backupPath: { type: "string" },
        },
        required: ["ok", "changedMessages", "changedEvents", "removedFields"],
        additionalProperties: false,
      },
      errors: { failed: { type: "null" } },
    },
  },
  events: {},
} as const

// Never display raw subprocess, provider or RPC error strings (may contain secrets).
export const reasons = {
  version: "仅支持 OpenCode 2.0.24+de2cacd，请检查正在运行的客户端和服务版本",
  location: "无法确认当前会话所属位置",
  database: "无法确认服务实际使用的本地数据库",
  runtime: "未配置可信的独立 Bun 运行时，请完成安装并重启服务",
  busy: "当前会话已有清理操作正在进行",
  stopped: "停止或等待会话结束失败，未执行清理",
  cancelled: "操作已取消或超时；若已启动清理，请检查备份和数据库状态",
  helper: "清理进程未确认成功，请检查备份和数据库状态",
  refresh: "清理已提交，但界面刷新失败；请重新打开会话",
  unknown: "操作失败，请检查服务状态；若连接中断，请检查备份和数据库状态",
} as const

export function safeReason(error: unknown): string {
  const message = error && typeof error === "object" && "message" in error ? error.message : undefined
  return Object.values(reasons).find((value) => value === message) ?? reasons.unknown
}

export default definition
