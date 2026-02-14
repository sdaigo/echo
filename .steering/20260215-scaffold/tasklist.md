# タスクリスト

## タスク完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール

- **全てのタスクを`[x]`にすること**
- 「時間の都合により別タスクとして実施予定」は禁止
- 「実装が複雑すぎるため後回し」は禁止
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

### 実装可能なタスクのみを計画

- 計画段階で「実装可能なタスク」のみをリストアップ
- 「将来やるかもしれないタスク」は含めない
- 「検討中のタスク」は含めない

### タスクスキップが許可される唯一のケース

以下の技術的理由に該当する場合のみスキップ可能:

- 実装方針の変更により、機能自体が不要になった
- アーキテクチャ変更により、別の実装方法に置き換わった
- 依存関係の変更により、タスクが実行不可能になった

スキップ時は必ず理由を明記:

```markdown
- [x] ~~タスク名~~（実装方針変更により不要: 具体的な技術的理由）
```

### タスクが大きすぎる場合

- タスクを小さなサブタスクに分割
- 分割したサブタスクをこのファイルに追加
- サブタスクを1つずつ完了させる

---

## フェーズ1: TanStack Start プロジェクト初期化

> **依存**: なし（最初に実行）
> **注意**: TanStack Start は RC のため、インストール時のバージョンを `package.json` で完全固定する（`^` や `~` を使わず exact version）。`@tanstack/react-router` も同様に固定する。`docs/architecture.md` の依存関係管理ポリシーを参照。

- [x] `package.json` の作成と依存パッケージのインストール
  - [x] `bun init` でプロジェクトを初期化
  - [x] TanStack Start 関連パッケージをインストール（exact version で固定）
    - `@tanstack/react-start`, `@tanstack/react-router`, `@tanstack/react-router-devtools`
    - `@tanstack/react-query`, `@tanstack/react-query-devtools`
    - `react`, `react-dom`（実装方針変更: `vinxi` → `vite` + `nitro` に移行。TanStack Start が Vite + Nitro ベースに変更されたため）
  - [x] TypeScript 関連: `typescript`, `@types/react`, `@types/react-dom`
  - [x] バリデーション: `zod`
  - [x] `package.json` の `scripts` に以下を設定（実装方針変更: vinxi → vite コマンドに変更）
    - `"dev": "vite dev"`
    - `"build": "vite build"`
    - `"start": "node .output/server/index.mjs"`

- [x] `tsconfig.json` の作成
  - [x] `compilerOptions.paths` でパスエイリアスを設定: `"@/*": ["./src/*"]`, `"@app/*": ["./app/*"]`
  - [x] `strict: true`, `jsx: "react-jsx"`, `moduleResolution: "bundler"` 等の設定
  - [x] `include`: `["**/*.ts", "**/*.tsx"]`

- [x] `vite.config.ts` の作成（実装方針変更: `app.config.ts` → `vite.config.ts`。TanStack Start が Vite プラグインとして統合されたため）
  - [x] `tanstackStart` プラグイン（`srcDirectory: "app"`）
  - [x] Vite プラグインの設定（`@vitejs/plugin-react`, `vite-tsconfig-paths`, `nitro`）
  - [x] パスエイリアスは `vite-tsconfig-paths` 経由で tsconfig.json から自動解決

- [x] `app/router.tsx` の作成
  - [x] `createRouter` でルーターインスタンスを生成
  - [x] `routeTree` のインポート（自動生成ファイル `app/routeTree.gen.ts`）
  - [x] `QueryClient` のデフォルト設定

- [x] ~~`app/client.tsx` の作成~~（実装方針変更により不要: TanStack Start の `tanstackStart` Vite プラグインが自動処理）

- [x] ~~`app/ssr.tsx` の作成~~（実装方針変更により不要: TanStack Start の `tanstackStart` Vite プラグインが自動処理）

- [x] `app/routes/__root.tsx` の作成
  - [x] ルートレイアウト（`<html>`, `<head>`, `<body>` の基本構造）
  - [x] `<HeadContent />`, `<Scripts />` の TanStack Start ヘッドコンポーネント
  - [x] `shellComponent` パターンで子ルートをレンダリング
  - [x] 認証ガードは配置しない（F1 スコープ）

- [x] `app/routes/index.tsx` の作成
  - [x] プレースホルダーページ（「Echo - Scaffold complete.」テキスト表示）
  - [x] `createFileRoute` でルート定義

- [x] フェーズ1 動作確認
  - [x] `bun install` が成功する
  - [x] `bun run dev` で開発サーバーが起動する（port 3000）
  - [x] ブラウザで `http://localhost:3000` にアクセスしてプレースホルダーページが表示される
  - [x] `bun run build` でビルドが成功する

## フェーズ2: 開発ツールとプロジェクト環境の設定

> **依存**: フェーズ1（package.json、プロジェクト構造が必要）
> **目的**: 以降のフェーズで書くコードが最初から Biome でフォーマット・リントされるようにする

- [x] `biome.json` の作成（`docs/development-guidelines.md` の Biome 設定に準拠）
  - [x] `formatter.indentStyle`: `"tab"`
  - [x] `formatter.indentWidth`: `2`
  - [x] `formatter.lineWidth`: `100`
  - [x] `javascript.formatter.semicolons`: `"asNeeded"` (セミコロンなし)
  - [x] `javascript.formatter.quoteStyle`: `"double"`
  - [x] `linter.enabled`: `true` + 推奨ルールセット
  - [x] `files.ignore`: `["node_modules", "dist", ".output", "src/types/database.ts", "app/routeTree.gen.ts"]`
  - [x] devDependency に `@biomejs/biome` をインストール

- [x] `vitest.config.ts` の作成
  - [x] パスエイリアス（`@/` → `src/`, `@app/` → `app/`）の設定
  - [x] テスト対象パターン: `["src/**/*.test.ts", "src/**/*.test.tsx"]`
  - [x] `globals: true` で `describe`, `it`, `expect` をグローバル化
  - [x] devDependency に `vitest` をインストール

- [x] `playwright.config.ts` の作成
  - [x] `baseURL`: `"http://localhost:3000"`
  - [x] `testDir`: `"tests/e2e"`
  - [x] `testMatch`: `"**/*.spec.ts"`
  - [x] ブラウザ設定: Chromium（最小限。Safari/Firefox は機能実装時に追加検討）
  - [x] devDependency に `@playwright/test` をインストール

- [x] `.env.example` の作成（`docs/architecture.md` 環境変数一覧に準拠）
  - [x] `VITE_SUPABASE_URL=http://127.0.0.1:54321`
  - [x] `VITE_SUPABASE_ANON_KEY=your-anon-key`
  - [x] `SUPABASE_SERVICE_ROLE_KEY=your-service-role-key`
  - [x] `ALLOWED_EMAILS=you@example.com`

- [x] `.gitignore` の更新
  - [x] `node_modules/`, `dist/`, `.output/`
  - [x] `.env.local`, `.env.*.local`
  - [x] `supabase/.temp/`
  - [x] `test-results/`, `playwright-report/`
  - [x] `*.tsbuildinfo`
  - [x] `app/routeTree.gen.ts`（TanStack Router 自動生成）

- [x] `package.json` スクリプトの追加（フェーズ1で未設定のもの）
  - [x] `"test": "vitest run"`
  - [x] `"test:watch": "vitest"`
  - [x] `"test:e2e": "playwright test"`
  - [x] `"check": "biome check --write ."`
  - [x] `"typecheck": "tsc --noEmit"`
  - [x] `"db:migrate": "supabase db push"`
  - [x] `"db:reset": "supabase db reset"`
  - [x] `"db:types": "supabase gen types typescript --local > src/types/database.ts"`

- [x] フェーズ2 動作確認
  - [x] `bun run check` で Biome チェックが実行される（エラーがあれば修正）
  - [x] `bun run test` で Vitest が実行される（テスト0件でエラーなく完了）
  - [x] `bun run typecheck` で型チェックが通る

## フェーズ3: UI ライブラリのセットアップ

> **依存**: フェーズ1（TanStack Start プロジェクトが起動可能であること）、フェーズ2（Biome が設定済み）
> **注意**: Tailwind CSS v4 は v3 とセットアップ方法が異なる。`tailwind.config.ts` ではなく CSS ファイル内の `@import "tailwindcss"` で設定する。

- [x] Tailwind CSS v4 のインストールと設定
  - [x] `tailwindcss`, `@tailwindcss/vite` をインストール
  - [x] `vite.config.ts` の Vite プラグインに `@tailwindcss/vite` を追加
  - [x] `src/styles/globals.css` を作成: `@import "tailwindcss";` を記述
  - [x] `app/routes/__root.tsx` で `src/styles/globals.css` を `?url` import + `head.links` で読み込み

- [x] shadcn/ui の初期化
  - [x] `components.json` を作成（手動）
    - `style`: `"new-york"`
    - `tailwind.css`: `"src/styles/globals.css"`
    - `aliases.components`: `"@/components"`
    - `aliases.utils`: `"@/lib/utils"`
  - [x] `src/lib/utils.ts` を作成: `cn()` ユーティリティ関数（`clsx` + `tailwind-merge`）
  - [x] `clsx`, `tailwind-merge`, `class-variance-authority` をインストール

- [x] 基本コンポーネントの追加
  - [x] `bunx shadcn@latest add button` → `src/components/ui/button.tsx`
  - [x] `bunx shadcn@latest add input` → `src/components/ui/input.tsx`
  - [x] `bunx shadcn@latest add textarea` → `src/components/ui/textarea.tsx`

- [x] フェーズ3 動作確認
  - [x] `bun run build` でビルド成功（CSS 10.86kB 生成確認）
  - [x] プレースホルダーページに Tailwind のユーティリティクラスを適用しスタイルが反映される
  - [x] `bun run check` で Biome チェックが通る
  - [x] `bun run typecheck` で型チェックが通る

## フェーズ4: Supabase ローカル開発環境

> **依存**: フェーズ1（package.json の db:* スクリプトが設定済み）
> **前提**: Docker Desktop が起動していること、Supabase CLI がインストール済みであること
> **参照**: `docs/functional-design.md` の「データモデル定義」「インデックス」「RLS」セクション

- [x] Supabase プロジェクトの初期化
  - [x] `supabase init` を実行（`supabase/config.toml` が生成される）
  - [x] `supabase/config.toml` でプロジェクト名が `echo` に設定されている

- [x] 初期マイグレーションの作成: `supabase/migrations/20260215000000_init.sql`
  - [x] `pg_trgm` 拡張の有効化: `CREATE EXTENSION IF NOT EXISTS pg_trgm;`
  - [x] `posts` テーブルの作成
  - [x] `tags` テーブルの作成
  - [x] `post_tags` テーブルの作成
  - [x] インデックスの作成（3件）
  - [x] RLS の有効化と全ポリシーの設定（8ポリシー確認済み）

- [x] Supabase ローカル環境の起動確認
  - [x] `supabase start` でローカル Supabase が起動する
  - [x] マイグレーションが自動適用され、テーブルが作成されていることを確認（posts, tags, post_tags）
  - [x] RLS ポリシー 8件が正しく作成されていることを確認

- [x] DB 型定義の生成
  - [x] `src/types/` ディレクトリを作成
  - [x] `bun run db:types` を実行し、`src/types/database.ts` が生成されることを確認
  - [x] 生成された型に `posts`, `tags`, `post_tags` の定義が含まれていることを確認

- [x] フェーズ4 動作確認
  - [x] `supabase status` でローカル環境の接続情報が表示される
  - [x] `bun run typecheck` で型チェックが通る（database.ts が正しく生成されていること）

## フェーズ5: アプリケーション基盤コード

> **依存**: フェーズ4（Supabase 型定義が必要）、フェーズ3（utils.ts が存在すること）

- [x] Supabase クライアントの作成
  - [x] `@supabase/supabase-js`, `@supabase/ssr` をインストール
  - [x] `src/lib/supabase/client.ts` を作成
    - `getClientSupabase()` 関数: `createBrowserClient` を使用
    - 環境変数: `import.meta.env.VITE_SUPABASE_URL`, `import.meta.env.VITE_SUPABASE_ANON_KEY`
    - `src/types/database.ts` の `Database` 型をジェネリクスに渡す
  - [x] `src/lib/supabase/server.ts` をスケルトンとして作成
    - `getServerSupabase()` 関数のスケルトン（Cookie セッション対応は F1 で実装）
    - コメントで F1 での実装内容を記載

- [x] アプリ定数の定義: `src/lib/constants.ts`
  - [x] `MAX_POST_LENGTH = 280`
  - [x] `MAX_TAG_LENGTH = 50`
  - [x] `MAX_TAGS_PER_POST = 10`
  - [x] `DEFAULT_PAGE_SIZE = 20`
  - [x] `SEARCH_DEBOUNCE_MS = 300`

- [x] 共通型定義のスケルトン: `src/types/common.ts`
  - [x] `PaginatedResponse<T>` 型（`data`, `nextCursor`, `hasMore`）

- [x] サンプルユニットテスト: `src/lib/constants.test.ts`
  - [x] `MAX_POST_LENGTH` が 280 であることを検証するテスト（5件のテスト全pass）
  - [x] Vitest が正しく動作することの確認を兼ねる

- [x] feature ディレクトリ構造の作成（空ディレクトリに `.gitkeep` を配置）
  - [x] `src/features/auth/components/`, `src/features/auth/server/`, `src/features/auth/types/`
  - [x] `src/features/post/components/`, `src/features/post/hooks/`, `src/features/post/server/`, `src/features/post/types/`
  - [x] `src/features/tag/components/`, `src/features/tag/hooks/`, `src/features/tag/server/`, `src/features/tag/types/`
  - [x] `src/features/search/components/`, `src/features/search/hooks/`, `src/features/search/server/`, `src/features/search/types/`

- [x] 共有コンポーネントディレクトリ: `src/components/layout/`
  - [x] `.gitkeep` を配置（`app-header.tsx` は F1 以降で作成）

- [x] テストディレクトリ構造の作成
  - [x] `tests/e2e/` + `.gitkeep`
  - [x] `tests/integration/` + `.gitkeep`
  - [x] `tests/helpers/` + `.gitkeep`

- [x] フェーズ5 動作確認
  - [x] `bun run test` でサンプルテストが通る（5件 pass）
  - [x] `bun run typecheck` で型チェックが通る
  - [x] `bun run check` で Biome チェックが通る

## 最終フェーズ: 品質チェックとドキュメント更新

- [x] 全体テストの実行
  - [x] `bun run dev` で開発サーバーが起動する
  - [x] `bun run build` でビルドが成功する（client 340kB + CSS 11kB, SSR, Nitro全て成功）
  - [x] `bun run test` でテストが通る（5件 pass）
  - [x] `bun run check` で Biome チェックが通る
  - [x] `bun run typecheck` で型チェックが通る
  - [x] `supabase start` → テーブル・RLS が正しく作成されている

- [x] 受け入れ条件の最終確認（`requirements.md` に対応）
  - [x] ブラウザで `http://localhost:3000` にアクセスできる
  - [x] パスエイリアス `@/` と `@app/` が動作する（typecheck通過で確認）
  - [x] `docs/project-structure.md` に定義された構造が作成されている
  - [x] `bun run db:types` で型定義ファイルが再生成できる
  - [x] Tailwind CSS v4 のユーティリティクラスが動作する（ビルドでCSS 11kB生成）
  - [x] shadcn/ui のコンポーネントが利用可能（button, input, textarea）
  - [x] TanStack Start / Router のバージョンが `package.json` で完全固定されている

- [x] 自分で自分の成果物に対し、批判的レビューを行ったか（3点指摘: radix-ui ^除去、env.d.ts作成、supabase/config.toml確認）
- [x] `docs/glossary.md` の用語と完全に一致しているか（code-reviewerが確認）
- [x] ドキュメント更新（レビュー指摘に基づきマイグレーション修正: tags_delete追加、post_tagsインデックス追加、UPDATE不可の設計意図コメント追加、.gitignore強化）
- [x] 実装後の振り返り（このファイルの下部に記録）

---

## 実装後の振り返り

### 実装完了日

2026-02-15

### 計画と実績の差分

**計画と異なった点**:

- TanStack Start が `vinxi` から `vite` + `nitro` ベースに移行していた。`app.config.ts` → `vite.config.ts`、`client.tsx`/`ssr.tsx` が不要に（プラグインが自動処理）、コマンドが `vinxi *` → `vite *` に変更
- `@tanstack/react-query-devtools` のバージョン 5.90.21 が存在せず、5.91.3 を使用
- `class-variance-authority` が shadcn/ui の依存として自動インストールされず、手動追加が必要だった
- Vitest がテストファイル0件の場合に exit code 1 を返す仕様のため、`passWithNoTests: true` を追加
- `import.meta.env` が `string | undefined` を返すため、Supabase クライアントで環境変数バリデーション関数を追加

**新たに必要になったタスク**:

- レビュー指摘に基づく修正: `tags_delete` RLS ポリシー追加、`post_tags(tag_id)` インデックス追加、UPDATE 不可の設計意図をコメントで明示
- `src/env.d.ts` の作成（Vite 型定義のグローバル参照）
- `radix-ui` の `^` プレフィックス除去（exact version ポリシー違反）
- `.gitignore` の強化（`.env.*` パターンで全バリエーション保護）

**技術的理由でスキップしたタスク**:

- `app/client.tsx` の作成（実装方針変更により不要: TanStack Start の `tanstackStart` Vite プラグインが自動処理）
- `app/ssr.tsx` の作成（同上）

### 学んだこと

**技術的な学び**:

- TanStack Start 1.x は Vite プラグイン + Nitro ベースのアーキテクチャに移行しており、公式ドキュメントより先に npm/GitHub の最新コードを確認する必要がある
- `tanstackStart({ srcDirectory: "app" })` で `app/` ディレクトリを分離可能。`src/` との2ディレクトリ構成が実現できた
- CSS の読み込みは `?url` import + `head.links` パターンを使用。`shellComponent` パターンでルートレイアウトを定義
- Tailwind CSS v4 は `@import "tailwindcss"` のみで設定完了。`tailwind.config.ts` は不要

**プロセス上の改善点**:

- PROACTIVE エージェント（code-reviewer, security-reviewer, db-reviewer）の並行実行により、手動レビューでは見落としやすい RLS ポリシーの不備やインデックスの欠落を検出できた
- tasklist.md の即時更新は進捗の可視化に有効。Phase 5 での更新遅延は改善すべき点

### 次回への改善提案

- TanStack Start のバージョン固定に加え、Vite や Nitro のバージョンも固定すべき（現在 Nitro は alpha）
- RLS ポリシー設計時に、全 CRUD 操作に対するポリシーの要否を明示的に記載する（「不要」も含めて）
- tasklist.md の更新を各タスク完了直後に行う習慣を徹底する（Phase 5 では遅延があった）
