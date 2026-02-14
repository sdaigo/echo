# プロジェクト構造定義書 (Project Structure Document)

## ルートディレクトリ構成

```text
/
├── app/                          # TanStack Start アプリケーションエントリ
├── src/                          # アプリケーションソースコード
├── supabase/                     # Supabase ローカル開発 & マイグレーション
├── tests/                        # 統合テスト・E2Eテスト
├── public/                       # 静的アセット（favicon等）
├── docs/                         # プロジェクトドキュメント
├── .claude/                      # Claude Code 設定
├── package.json
├── tsconfig.json
├── biome.json
├── app.config.ts                 # TanStack Start 設定
├── .env.local                    # 環境変数（ローカル）※Git管理外
└── .env.example                  # 環境変数テンプレート
```

## ソースコード構造

### 全体構成

```text
app/                              # TanStack Start エントリ（ルーティング）
src/
├── features/                     # 機能モジュール（ドメインロジック + UI + サーバー関数）
├── components/                   # 共有UIコンポーネント
├── lib/                          # 共有ユーティリティ
└── types/                        # 共有型定義
```

### TanStack Start エントリ (`app/`)

**責務**: ルーティング定義、アプリケーションのエントリポイント。TanStack Start の規約に従う。

```text
app/
├── routes/                       # ファイルベースルーティング
│   ├── __root.tsx                # ルートレイアウト（認証ガード、共通レイアウト）
│   ├── index.tsx                 # タイムライン画面 (/)
│   └── login.tsx                 # ログイン画面 (/login)
├── client.tsx                    # クライアントエントリポイント
├── router.tsx                    # ルーター設定
├── ssr.tsx                       # SSR設定
└── routeTree.gen.ts              # 自動生成ルートツリー ※手動編集禁止
```

| ファイル | 責務 | 備考 |
|:---|:---|:---|
| `routes/__root.tsx` | 認証チェック、共通HTMLレイアウト | 未認証時は `/login` にリダイレクト |
| `routes/index.tsx` | PostComposer + Timeline の組み立て | メイン画面。features/ のコンポーネントを利用 |
| `routes/login.tsx` | OAuthプロバイダ選択UI | 認証済みなら `/` にリダイレクト |
| `client.tsx` | クライアントサイドハイドレーション | TanStack Start 規約 |
| `router.tsx` | ルーター生成・QueryClient設定 | TanStack Start 規約 |
| `ssr.tsx` | サーバーサイドレンダリングエントリ | TanStack Start 規約 |

### 機能モジュール (`src/features/`)

**責務**: ドメイン固有のビジネスロジック・UI・サーバー関数・型定義を機能単位でカプセル化する。

```text
src/features/
├── auth/                         # 認証機能
│   ├── components/
│   │   └── login-form.tsx        # OAuthボタン群
│   ├── server/
│   │   └── auth.ts               # セッション検証、許可リストチェック
│   ├── types/
│   │   └── auth-types.ts         # Session, AllowedUser 等
│   └── index.ts                  # 公開API
│
├── post/                         # 投稿機能
│   ├── components/
│   │   ├── post-composer.tsx      # 投稿フォーム
│   │   ├── post-card.tsx          # 投稿カード
│   │   └── timeline.tsx           # タイムライン一覧
│   ├── hooks/
│   │   ├── use-create-post.ts     # 投稿作成 mutation
│   │   ├── use-delete-post.ts     # 投稿削除 mutation
│   │   └── use-list-posts.ts      # タイムライン取得 infinite query
│   ├── server/
│   │   ├── create-post.ts         # createPost Server Function
│   │   ├── delete-post.ts         # deletePost Server Function
│   │   └── list-posts.ts          # listPosts Server Function
│   ├── types/
│   │   └── post-types.ts          # Post, PostWithTags, CreatePostInput 等
│   └── index.ts
│
├── tag/                          # タグ機能
│   ├── components/
│   │   └── tag-input.tsx          # タグ入力（オートコンプリート）
│   ├── hooks/
│   │   └── use-list-tags.ts       # タグ一覧取得 query
│   ├── server/
│   │   └── list-tags.ts           # listTags Server Function
│   ├── types/
│   │   └── tag-types.ts           # Tag 型
│   └── index.ts
│
└── search/                       # 検索機能
    ├── components/
    │   └── search-bar.tsx         # 検索バー
    ├── hooks/
    │   └── use-search-posts.ts    # 検索 query
    ├── server/
    │   └── search-posts.ts        # searchPosts Server Function
    ├── types/
    │   └── search-types.ts        # SearchInput, SearchResult 等
    └── index.ts
```

| feature | 責務 | 主要コンポーネント |
|:---|:---|:---|
| `auth/` | OAuth認証、セッション管理、許可リストチェック | LoginForm |
| `post/` | 投稿の作成・削除・一覧表示 | PostComposer, Timeline, PostCard |
| `tag/` | タグの管理・オートコンプリート | TagInput |
| `search/` | 全文検索 | SearchBar |

### 共有UIコンポーネント (`src/components/`)

**責務**: 機能横断で再利用されるUIコンポーネント。

```text
src/components/
├── ui/                           # shadcn/ui コンポーネント群
│   ├── button.tsx
│   ├── dialog.tsx
│   ├── input.tsx
│   ├── textarea.tsx
│   ├── badge.tsx
│   ├── toast.tsx
│   └── ...
└── layout/                       # レイアウト部品
    └── app-header.tsx             # アプリヘッダー（タイトル、検索、ログアウト）
```

| ディレクトリ | 責務 | 備考 |
|:---|:---|:---|
| `ui/` | shadcn/ui のコピーベースコンポーネント | `bunx shadcn@latest add` で追加 |
| `layout/` | ページレイアウトの共通部品 | 機能固有でないレイアウト要素 |

### 共有ユーティリティ (`src/lib/`)

**責務**: 機能横断で使用されるユーティリティ関数・設定。

```text
src/lib/
├── supabase/
│   ├── client.ts                 # ブラウザ用 Supabase クライアント
│   ├── server.ts                 # Server Functions 用 Supabase クライアント
│   └── middleware.ts             # セッション更新ミドルウェア
├── constants.ts                  # アプリ全体の定数（MAX_POST_LENGTH 等）
└── utils.ts                      # 汎用ユーティリティ（日付フォーマット等）
```

| ファイル | 責務 | 備考 |
|:---|:---|:---|
| `supabase/client.ts` | ブラウザ環境用の Supabase クライアント生成 | `VITE_SUPABASE_URL` + `VITE_SUPABASE_ANON_KEY` |
| `supabase/server.ts` | サーバー環境用の Supabase クライアント生成 | Cookie経由のセッション復元 |
| `supabase/middleware.ts` | リクエストごとのセッショントークン更新 | `@supabase/ssr` を利用 |

### 共有型定義 (`src/types/`)

**責務**: 機能横断の型定義。DB型の自動生成先。

```text
src/types/
├── database.ts                   # Supabase CLI で自動生成されるDB型
└── common.ts                     # PaginatedResponse 等の共通型
```

### Supabase (`supabase/`)

**責務**: ローカル開発環境の設定とDBマイグレーション管理。

```text
supabase/
├── migrations/                   # SQLマイグレーションファイル
│   └── 20260215000000_init.sql   # 初期スキーマ（posts, tags, post_tags, RLS）
├── seed.sql                      # 開発用シードデータ
└── config.toml                   # Supabase CLI 設定
```

## 命名規則

### ファイル名

| 種別 | 規則 | 例 |
|:---|:---|:---|
| コンポーネント | kebab-case | `post-card.tsx` |
| hooks | `use-` prefix + kebab-case | `use-create-post.ts` |
| Server Function | kebab-case（動詞始まり） | `create-post.ts` |
| 型定義 | kebab-case + `-types` suffix | `post-types.ts` |
| テスト | `*.test.ts(x)` | `post-card.test.tsx` |
| 定数 | kebab-case | `constants.ts` |
| barrel file | `index.ts` | `index.ts` |

### ディレクトリ名

| 規則 | 例 |
|:---|:---|
| kebab-case | `post-card/` |
| 機能単位は単数形 | `post/`, `auth/`, `search/` |
| レイヤー単位は複数形 | `components/`, `hooks/`, `types/` |

### エクスポート規則

| 種別 | 規則 | 例 |
|:---|:---|:---|
| コンポーネント | PascalCase (named export) | `export function PostCard()` |
| hooks | camelCase (named export) | `export function useCreatePost()` |
| Server Function | camelCase (named export) | `export const createPost = createServerFn(...)` |
| 型 | PascalCase (named export) | `export type PostWithTags = {...}` |
| 定数 | UPPER_SNAKE_CASE | `export const MAX_POST_LENGTH = 280` |
| デフォルトエクスポート | 原則禁止 | barrel file (index.ts) も named export のみ |

## モジュール境界と依存関係ルール

### 依存方向

```text
app/routes/          (ルーティング)
    ↓
src/features/*/      (機能モジュール)
    ↓
src/components/      (共有UI)
src/lib/             (共有ユーティリティ)
src/types/           (共有型定義)
```

### レイヤー別の依存ルール

| レイヤー | 許可される依存先 | 禁止される依存先 |
|:---|:---|:---|
| `app/routes/` | `src/features/`, `src/components/`, `src/lib/`, `src/types/` | `supabase/` への直接アクセス |
| `src/features/*/components/` | 同feature内, `src/components/`, `src/lib/`, `src/types/` | 他featureへの直接依存、`src/lib/supabase/` |
| `src/features/*/hooks/` | 同feature内の `server/`, `types/`, `src/lib/`, `src/types/` | 他featureへの直接依存 |
| `src/features/*/server/` | `src/lib/supabase/`, `src/lib/`, `src/types/`, 同feature `types/` | `src/components/`, 他feature |
| `src/components/` | `src/lib/`, `src/types/` | `src/features/`, `app/`, `src/lib/supabase/` |
| `src/lib/` | `src/types/` | `src/features/`, `src/components/`, `app/` |

### feature間の依存ルール

```text
feature間の直接依存は禁止:
  post/ → tag/        (NG)
  search/ → post/     (NG)

feature間で共有が必要な場合:
  → 共有部分を src/lib/ または src/types/ に昇格
```

## パスエイリアス

| エイリアス | パス | 用途 |
|:---|:---|:---|
| `@/` | `src/` | アプリケーションソースコード |
| `@app/` | `app/` | TanStack Start エントリ |

**tsconfig.json での設定**:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@app/*": ["./app/*"]
    }
  }
}
```

## 設定ファイル一覧

| ファイル | 役割 | Git管理 |
|:---|:---|:---|
| `package.json` | 依存関係、スクリプト定義 | Yes |
| `tsconfig.json` | TypeScript設定、パスエイリアス | Yes |
| `biome.json` | Linter + Formatter設定 | Yes |
| `app.config.ts` | TanStack Start アプリケーション設定 | Yes |
| `.env.example` | 環境変数テンプレート | Yes |
| `.env.local` | 環境変数（ローカル） | No |
| `supabase/config.toml` | Supabase CLI設定 | Yes |
| `bun.lockb` | 依存関係ロックファイル | Yes |
| `.gitignore` | Git除外設定 | Yes |
| `playwright.config.ts` | Playwright E2Eテスト設定 | Yes |
| `vitest.config.ts` | Vitest テスト設定 | Yes |
| `components.json` | shadcn/ui 設定 | Yes |

## テストファイル配置

### 配置ルール

| テスト種別 | 配置場所 | ファイル命名 | 理由 |
|:---|:---|:---|:---|
| ユニットテスト | ソースファイルと同階層 | `*.test.ts(x)` | コロケーションで保守性向上 |
| 統合テスト | `tests/integration/` | `*.test.ts(x)` | 複数モジュールの結合テスト |
| E2Eテスト | `tests/e2e/` | `*.spec.ts` | Playwright規約に合わせる |
| テストヘルパー | `tests/helpers/` | `*.ts` | モック、ファクトリ等 |

### テスト構造

```text
tests/
├── e2e/                          # E2Eテスト（Playwright）
│   ├── auth.spec.ts              # 認証フローのE2E
│   ├── post.spec.ts              # 投稿フローのE2E
│   └── search.spec.ts            # 検索フローのE2E
├── integration/                  # 統合テスト
│   ├── post-flow.test.ts         # 投稿作成→タイムライン表示
│   └── tag-filter.test.ts        # タグ付き投稿→フィルタリング
└── helpers/                      # テストユーティリティ
    ├── supabase-mock.ts          # Supabase クライアントモック
    ├── factories.ts              # テストデータファクトリ
    └── setup.ts                  # テスト共通セットアップ
```

### ユニットテストの配置例

```text
src/features/post/
├── components/
│   ├── post-composer.tsx
│   ├── post-composer.test.tsx    # ← コンポーネントの隣に配置
│   ├── post-card.tsx
│   └── post-card.test.tsx
├── hooks/
│   ├── use-create-post.ts
│   └── use-create-post.test.ts
└── server/
    ├── create-post.ts
    └── create-post.test.ts
```

## 新規ファイル追加ガイド

### 判断フローチャート

```text
新しいファイルを追加する場合:

1. 特定の機能（auth/post/tag/search）に閉じているか？
   → Yes: src/features/[feature名]/ に配置
   → No: 次へ

2. UIコンポーネントか？
   → Yes: 機能固有なら features/[name]/components/、汎用なら src/components/
   → No: 次へ

3. Server Function か？
   → Yes: src/features/[feature名]/server/ に配置
   → No: 次へ

4. TanStack Query の hook か？
   → Yes: src/features/[feature名]/hooks/ に配置
   → No: 次へ

5. 複数の feature から使われるユーティリティか？
   → Yes: src/lib/ に配置
   → No: 次へ

6. 型定義のみか？
   → Yes: 機能固有なら features/[name]/types/、共通なら src/types/
```

### 具体例

| 作りたいもの | 配置先 | 理由 |
|:---|:---|:---|
| 投稿の楽観的更新ロジック | `src/features/post/hooks/use-create-post.ts` | post機能に閉じたhook |
| 日付フォーマット関数 | `src/lib/utils.ts` | 複数featureから利用 |
| Toastコンポーネント | `src/components/ui/toast.tsx` | shadcn/ui の汎用コンポーネント |
| DB型定義 | `src/types/database.ts` | Supabase CLIで自動生成。全featureから参照 |
| 新しいマイグレーション | `supabase/migrations/` | タイムスタンプ付きSQLファイル |
| 新しいルート（将来） | `app/routes/` | TanStack Start のファイルベースルーティング |
