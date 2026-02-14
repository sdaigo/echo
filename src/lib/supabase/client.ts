import type { Database } from "@/types/database"
import { createBrowserClient } from "@supabase/ssr"

function getEnvVar(key: string): string {
	const value = import.meta.env[key]
	if (!value) {
		throw new Error(`Missing environment variable: ${key}`)
	}
	return value
}

export function getClientSupabase() {
	return createBrowserClient<Database>(
		getEnvVar("VITE_SUPABASE_URL"),
		getEnvVar("VITE_SUPABASE_ANON_KEY"),
	)
}
