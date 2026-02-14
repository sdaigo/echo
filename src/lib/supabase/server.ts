import type { Database } from "@/types/database"

// F1 (OAuth認証) で Cookie セッション対応を実装予定:
// - @supabase/ssr の createServerClient を使用
// - Server Functions 内で Cookie からセッションを復元
// - getWebRequest() からリクエストヘッダーを取得
export function getServerSupabase(): never {
	throw new Error("Not implemented. Will be implemented in F1 (OAuth auth).")
}

export type { Database }
