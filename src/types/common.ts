export type PaginatedResponse<T> = {
	readonly data: readonly T[]
	readonly nextCursor: string | null
	readonly hasMore: boolean
}
