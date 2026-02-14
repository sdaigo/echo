import { createFileRoute } from "@tanstack/react-router"

export const Route = createFileRoute("/")({
  component: Home,
})

function Home() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h1 className="text-2xl font-bold">Echo</h1>
        <p className="mt-2 text-muted-foreground">Scaffold complete.</p>
      </div>
    </div>
  )
}
