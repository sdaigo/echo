import { resolve } from "node:path"
import { defineConfig } from "vitest/config"

export default defineConfig({
  resolve: {
    alias: {
      "@": resolve(__dirname, "./src"),
      "@app": resolve(__dirname, "./app"),
    },
  },
  test: {
    globals: true,
    include: ["src/**/*.test.ts", "src/**/*.test.tsx", "app/**/*.test.ts", "app/**/*.test.tsx"],
    passWithNoTests: true,
  },
})
