import { QueryClient } from "@tanstack/react-query"
import { createRouter } from "@tanstack/react-router"
import { routeTree } from "./routeTree.gen"

export type RouterContext = {
  readonly queryClient: QueryClient
}

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // 分報は頻繁な更新が不要なため、60秒キャッシュを保持
      staleTime: 1000 * 60,
    },
  },
})

export function getRouter() {
  const router = createRouter({
    routeTree,
    context: { queryClient },
    defaultPreload: "intent",
    scrollRestoration: true,
  })
  return router
}

declare module "@tanstack/react-router" {
  interface Register {
    router: ReturnType<typeof getRouter>
  }
}
