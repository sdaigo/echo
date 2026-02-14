# 開発ガイドライン (Development Guidelines)

> **汎用原則**: `.claude/rules/common/` に定義された以下のルールがベースとして適用される。本ドキュメントはプロジェクト固有の設定のみを記載する。
>
> - `coding-style.md` - 命名規則、型安全、関数設計、イミュータビリティ
> - `testing.md` - TDD、カバレッジ、AAA、モック原則
> - `git-workflow.md` - ブランチ戦略、Conventional Commits、レビュー基準
> - `security.md` - 入力バリデーション、認証・認可、OWASP Top 10

## コードフォーマット

### Biome 設定

| 項目 | 設定値 |
|:---|:---|
| インデント | タブ (Biome デフォルト) |
| インデント幅 | 2 |
| 行の長さ | 100文字 |
| セミコロン | なし |
| クォート | ダブルクォート |

Biome は `.claude/hooks/auto-format.sh` により Edit/Write 後に自動実行される。

## プロジェクト固有のコーディング規約

### TanStack Start Server Functions

Server Functions は `createServerFn` で定義し、feature ごとのファイルに配置する。

```typescript
// src/features/post/server/create-post.ts
import { createServerFn } from "@tanstack/react-start"
import { z } from "zod"

const createPostSchema = z.object({
  content: z.string().min(1).max(280),
  tagNames: z.array(z.string().min(1).max(50)).max(10).default([]),
})

export const createPost = createServerFn({ method: "POST" })
  .validator(createPostSchema)
  .handler(async ({ data }) => {
    const supabase = await getServerSupabase()
    // ...
  })
```

**規約**:
- 1ファイル1 Server Function
- ファイル名は Server Function 名と一致させる（kebab-case）
- バリデーションスキーマは同ファイル内に定義
- 全 Server Function の先頭でセッション検証を行う

### TanStack Query hooks

データ取得・変更は TanStack Query の hook で抽象化する。

```typescript
// src/features/post/hooks/use-create-post.ts
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { createPost } from "@/features/post/server/create-post"

export function useCreatePost() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: createPost,
    onMutate: async (newPost) => {
      // 楽観的更新
      await queryClient.cancelQueries({ queryKey: ["posts"] })
      const previous = queryClient.getQueryData(["posts"])
      // ... キャッシュ更新
      return { previous }
    },
    onError: (_err, _variables, context) => {
      // ロールバック
      queryClient.setQueryData(["posts"], context?.previous)
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["posts"] })
    },
  })
}
```

**規約**:
- hook名は `use` + 動作 + エンティティ（例: `useCreatePost`, `useListPosts`）
- QueryKey は `[エンティティ名, ...フィルタ]` の形式（例: `["posts", { tag: "設計" }]`）
- 楽観的更新は mutation hook 内に実装

### Supabase クライアント

```typescript
// ブラウザ用: src/lib/supabase/client.ts
import { createBrowserClient } from "@supabase/ssr"

export function getClientSupabase() {
  return createBrowserClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_ANON_KEY,
  )
}

// サーバー用: src/lib/supabase/server.ts
// Server Functions 内でのみ使用。Cookie からセッションを復元
```

**規約**:
- UIコンポーネントから Supabase クライアントを直接呼ばない
- データ操作は必ず Server Functions 経由
- `SUPABASE_SERVICE_ROLE_KEY` はサーバーサイドでのみ使用

### コンポーネント設計

shadcn/ui ベースのコンポーネントを使用する。

**規約**:
- shadcn/ui コンポーネントは `src/components/ui/` に配置（`bunx shadcn@latest add` で追加）
- 機能固有コンポーネントは `src/features/[name]/components/` に配置
- Props は `readonly` を付ける（イミュータビリティ原則）
- イベントハンドラ Props は `on` prefix、内部ハンドラは `handle` prefix

## Git 運用（プロジェクト固有）

### コミットスコープ

`rules/common/git-workflow.md` の Conventional Commits に加え、以下のスコープを使用する。

| scope | 対象 |
|:---|:---|
| `auth` | 認証機能 |
| `post` | 投稿機能 |
| `tag` | タグ機能 |
| `search` | 検索機能 |
| `ui` | 共通UIコンポーネント |
| `db` | マイグレーション、スキーマ |
| `infra` | デプロイ、CI/CD |

**例**:
```text
feat(post): add text posting with Cmd+Enter shortcut
fix(auth): redirect unauthorized users to login page
test(tag): add autocomplete unit tests
chore(db): add initial migration for posts and tags
```

### ブランチ命名

```text
feature/f1-oauth-auth
feature/f2-text-posting
feature/f3-timeline
feature/f4-tag
feature/f5-delete-post
feature/f6-search
```

PRD の機能ID（F1〜F6）をブランチ名に含めることで、機能とブランチの対応を明確にする。

## テスト（プロジェクト固有）

### テストツール

| ツール | 用途 |
|:---|:---|
| Vitest | ユニットテスト、統合テスト |
| Testing Library | コンポーネントテスト |
| MSW (Mock Service Worker) | Server Functions のモック |
| Playwright | E2E テスト |
| Supabase CLI | ローカルDB環境 |

### テストパターン

#### Server Function のテスト

```typescript
// src/features/post/server/create-post.test.ts
import { describe, it, expect, vi } from "vitest"

describe("createPost", () => {
  it("280文字以内のテキストで投稿を作成できる", async () => {
    // Arrange
    const input = { content: "テスト投稿", tagNames: ["test"] }

    // Act
    const result = await createPost({ data: input })

    // Assert
    expect(result.content).toBe("テスト投稿")
    expect(result.tags).toHaveLength(1)
  })

  it("空文字の投稿はバリデーションエラーになる", async () => {
    // Arrange
    const input = { content: "", tagNames: [] }

    // Act & Assert
    await expect(createPost({ data: input })).rejects.toThrow()
  })
})
```

#### コンポーネントのテスト

```typescript
// src/features/post/components/post-composer.test.tsx
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, it, expect } from "vitest"

describe("PostComposer", () => {
  it("Cmd+Enterで投稿が送信される", async () => {
    // Arrange
    const user = userEvent.setup()
    render(<PostComposer onPostCreated={vi.fn()} />)

    // Act
    const textarea = screen.getByRole("textbox")
    await user.type(textarea, "テスト投稿")
    await user.keyboard("{Meta>}{Enter}{/Meta}")

    // Assert
    // ...
  })
})
```

### 開発用スクリプト

```json
{
  "scripts": {
    "dev": "vinxi dev",
    "build": "vinxi build",
    "start": "vinxi start",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test",
    "check": "biome check --write .",
    "typecheck": "tsc --noEmit",
    "db:migrate": "supabase db push",
    "db:reset": "supabase db reset",
    "db:types": "supabase gen types typescript --local > src/types/database.ts"
  }
}
```

## コードレビュー（プロジェクト固有）

`rules/common/git-workflow.md` のレビュー基準に加え、以下を確認する。

### 追加チェックポイント

- [ ] Server Functions でセッション検証が行われているか
- [ ] Supabase クライアントが UI レイヤーから直接呼ばれていないか
- [ ] 新しい DB アクセスに RLS ポリシーが設定されているか
- [ ] TanStack Query の QueryKey が一貫した命名になっているか
- [ ] コンパクトUI（360px幅）でレイアウトが崩れないか

## 推奨開発ツール

| ツール | 用途 |
|:---|:---|
| Supabase CLI | ローカルでの Supabase 起動、マイグレーション管理 |
| Supabase Dashboard | テーブル確認、RLS ポリシーの検証 |
| React DevTools | コンポーネントツリー、Props の確認 |
| TanStack Query DevTools | キャッシュ状態、クエリの確認 |
