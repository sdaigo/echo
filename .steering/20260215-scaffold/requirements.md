# 要求内容

## 概要

Echo プロジェクトの初期スキャフォールディング。TanStack Start + Supabase の開発基盤を構築し、docs/ で定義したアーキテクチャとプロジェクト構造を実体化する。

## 背景

`/setup` で永続ドキュメント（PRD、機能設計書、アーキテクチャ設計書、プロジェクト構造定義書、開発ガイドライン、用語集）を作成済み。これらの設計を実際のコードベースとして具現化する必要がある。機能実装（F1〜F6）に着手する前に、開発基盤が正しくセットアップされていることが前提となる。

## 実装対象の機能

### 1. TanStack Start プロジェクト初期化

- TanStack Start でプロジェクトを初期化する
- TypeScript、Vite の設定を行う
- パスエイリアス（`@/`, `@app/`）を設定する

### 2. ディレクトリ構造の作成

- `docs/project-structure.md` に定義されたディレクトリ構造を作成する
- `app/routes/`、`src/features/`、`src/components/`、`src/lib/`、`src/types/` を配置する

### 3. Supabase ローカル開発環境

- Supabase CLI でローカル開発環境をセットアップする
- 初期マイグレーション（posts, tags, post_tags テーブル + RLS）を作成する
- DB型の自動生成スクリプトを設定する

### 4. UIライブラリのセットアップ

- Tailwind CSS v4 を設定する
- shadcn/ui を初期化し、基本コンポーネントを追加する

### 5. 開発ツールの設定

- Biome（Linter + Formatter）を設定する
- Vitest を設定する
- Playwright を設定する（設定ファイルのみ。テスト本体は機能実装時に作成）

### 6. 環境変数と設定ファイル

- `.env.example` を作成する
- `.gitignore` を適切に設定する

## 受け入れ条件

### TanStack Start プロジェクト

- [ ] `bun run dev` でローカル開発サーバーが起動する
- [ ] `bun run build` でビルドが成功する
- [ ] ブラウザで `http://localhost:3000` にアクセスできる
- [ ] パスエイリアス `@/` と `@app/` が動作する

### ディレクトリ構造

- [ ] `docs/project-structure.md` に定義された構造が作成されている
- [ ] 各ディレクトリの役割が明確（空ディレクトリには `.gitkeep` を配置）

### Supabase

- [ ] `supabase start` でローカル Supabase が起動する
- [ ] 初期マイグレーションが適用され、posts, tags, post_tags テーブルが作成される
- [ ] RLS ポリシーが全テーブルに設定されている
- [ ] `bun run db:types` で型定義ファイルが生成される

### UIライブラリ

- [ ] Tailwind CSS v4 のユーティリティクラスが動作する
- [ ] shadcn/ui のコンポーネントが利用可能

### 開発ツール

- [ ] `bun run check` で Biome のチェックが実行される
- [ ] `bun run test` で Vitest が実行される（テスト0件でもエラーなく完了）
- [ ] `bun run typecheck` で型チェックが通る

## 技術的制約

- TanStack Start RC のため、バージョンを固定する
- Supabase Free プランの制約に収まる構成にする
- `docs/architecture.md` に定義された依存関係管理ポリシーに従う

## 成功指標

- 全ての受け入れ条件が満たされている
- 開発者が `bun install && supabase start && bun run dev` の3コマンドで開発を開始できる

## スコープ外

以下はこのフェーズでは実装しない:

- OAuth 認証の実装（F1 で実装）
- 投稿・タグ・検索の UI/ロジック（F2〜F6 で実装）
- CI/CD パイプライン（`/setup-infra` で構築）
- デプロイ設定

## 参照ドキュメント

- `docs/product-requirements.md` - プロダクト要求定義書
- `docs/functional-design.md` - 機能設計書
- `docs/architecture.md` - アーキテクチャ設計書
- `docs/project-structure.md` - プロジェクト構造定義書
- `docs/development-guidelines.md` - 開発ガイドライン
- `docs/glossary.md` - 用語集
