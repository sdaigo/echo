---
name: infra-guide
description: デプロイ先の選定・インフラ構成の設計ガイド。プロジェクト初期のインフラ設計や、デプロイ先の変更時に使用する。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch
---

# Infrastructure Guide スキル

プロジェクトのデプロイ先選定とインフラ構成の設計を支援するスキルです。

## 使用タイミング

- プロジェクト初期のインフラ設計
- デプロイ先プラットフォームの選定・変更
- 本番環境のアーキテクチャ設計

## 前提条件

以下のドキュメントを読み込む:

- `docs/product-requirements.md` - 非機能要件、対象ユーザー数
- `docs/architecture.md` - 技術スタック、データ永続化戦略
- `docs/functional-design.md` - 機能一覧、外部連携

## 設計手順

### ステップ1: 要件の整理

以下の観点でプロジェクトの要件を整理する:

| 観点 | 確認項目 |
|:---|:---|
| アプリケーション種別 | SPA / SSR / SSG / ハイブリッド |
| ランタイム要件 | Node.js / Edge Runtime / Static |
| データベース | PostgreSQL / MySQL / SQLite / なし |
| 認証 | OAuth / メール認証 / 外部IdP |
| ファイルストレージ | 画像アップロード / ドキュメント / なし |
| リアルタイム | WebSocket / SSE / なし |
| バックグラウンド処理 | Cron / Queue / なし |
| 想定トラフィック | 月間PV / 同時接続数 |

### ステップ2: プラットフォーム選定

要件に基づいて最適なプラットフォームを提案する。

#### フロントエンドホスティング

| プラットフォーム | 適合パターン | 無料枠 | 特徴 |
|:---|:---|:---|:---|
| Vercel | Next.js / SSR + ISR | Hobby プラン | Next.js 公式、Edge Functions |
| Cloudflare Pages | SSG / 軽量 SSR | 無制限サイト | CDN 統合、Workers 連携 |
| Netlify | SSG / Jamstack | 100GB / 月 | フォーム処理、Split Testing |
| Fly.io | カスタムサーバー | 3 shared VMs | Docker ベース、グローバル配置 |

#### データベース

| サービス | 適合パターン | 無料枠 | 特徴 |
|:---|:---|:---|:---|
| Supabase | PostgreSQL + Auth + Storage | 500MB DB | RLS、リアルタイム、Auth統合 |
| Neon | PostgreSQL (サーバーレス) | 0.5GB | ブランチ、オートスケール |
| PlanetScale | MySQL (サーバーレス) | 5GB | ブランチ、スキーマ変更管理 |
| Turso | SQLite (エッジ) | 9GB | 超低レイテンシ、組み込み対応 |

#### ファイルストレージ

| サービス | 適合パターン | 無料枠 |
|:---|:---|:---|
| Supabase Storage | Supabase 利用時 | 1GB |
| Cloudflare R2 | 大容量、低コスト | 10GB |
| AWS S3 | エンタープライズ | 5GB (12ヶ月) |
| Uploadthing | 簡易アップロード | 2GB |

#### 認証

| サービス | 適合パターン | 特徴 |
|:---|:---|:---|
| Supabase Auth | Supabase 利用時 | DB 統合、RLS 連携 |
| Better Auth | セルフホスト | OSS、Drizzle 連携 |
| Clerk | 高機能認証 | 管理画面、Webhook |
| Auth.js | カスタマイズ重視 | OSS、多プロバイダ |

### ステップ3: 構成パターンの提案

プロジェクトの要件に最も適合するパターンを選定し、構成図を作成する。

#### パターンA: Vercel + Supabase（推奨: Next.js フルスタック）

```text
[Client] → [Vercel Edge Network]
               |
          [Next.js App]
               |
          [Supabase]
          ├── PostgreSQL (RLS)
          ├── Auth
          ├── Storage
          └── Realtime
```

適合条件:
- Next.js アプリケーション
- PostgreSQL + 認証 + ストレージが必要
- RLS によるマルチテナント対応
- サーバーレスで運用したい

#### パターンB: Cloudflare Pages + Neon（推奨: 軽量アプリ）

```text
[Client] → [Cloudflare CDN]
               |
          [Pages / Workers]
               |
          [Neon PostgreSQL]
```

適合条件:
- SSG 中心、一部 SSR
- グローバル低レイテンシが重要
- データベースは PostgreSQL のみ
- コストを最小化したい

#### パターンC: Fly.io + Supabase（推奨: カスタムサーバー）

```text
[Client] → [Fly.io Edge]
               |
          [Docker Container]
               |
          [Supabase PostgreSQL]
```

適合条件:
- WebSocket / リアルタイム通信が必要
- カスタムサーバーロジックが必要
- Docker でのデプロイが望ましい

### ステップ4: 環境構成の設計

#### 環境一覧

| 環境 | 用途 | ブランチ |
|:---|:---|:---|
| local | 開発 | feature/* |
| preview | PR プレビュー | PR ごとに自動生成 |
| staging | リリース前検証 | main |
| production | 本番 | release tag |

#### 環境変数の管理

```text
.env.local          # ローカル開発用（.gitignore）
.env.example        # テンプレート（コミット対象）
```

デプロイ先の環境変数は各プラットフォームの管理画面またはCLIで設定する:

```bash
# Vercel
bunx vercel env add VARIABLE_NAME

# Cloudflare
bunx wrangler secret put VARIABLE_NAME

# Fly.io
flyctl secrets set VARIABLE_NAME=value
```

### ステップ5: 監視・可観測性

#### 最低限の監視設定

| 監視対象 | ツール | 設定 |
|:---|:---|:---|
| アプリケーションエラー | Sentry | `@sentry/nextjs` 統合 |
| パフォーマンス | Vercel Analytics / Web Vitals | フレームワーク統合 |
| 外形監視 | UptimeRobot / Better Stack | HTTP チェック |
| ログ | プラットフォーム組み込み | デプロイ先に依存 |

#### Sentry 導入手順

```bash
bun add @sentry/nextjs
bunx @sentry/wizard@latest -i nextjs
```

### ステップ6: ドキュメント出力

設計結果を `docs/architecture.md` のインフラセクションに追記する:

```markdown
## インフラ構成

### デプロイ先
- フロントエンド: [選定したプラットフォーム]
- データベース: [選定したサービス]
- ファイルストレージ: [選定したサービス]
- 認証: [選定したサービス]

### 環境構成
[環境一覧テーブル]

### 監視
[監視設定テーブル]
```

## チェックリスト

インフラ設計完了後に確認:

- [ ] アプリケーション種別に適合するプラットフォームを選定した
- [ ] 無料枠の制限がプロジェクトの要件を満たしている
- [ ] データベースのバックアップ戦略がある
- [ ] 環境変数の管理方法が決まっている
- [ ] 本番環境への承認フロー（GitHub Environments）が設計されている
- [ ] 最低限の監視（エラー検知、外形監視）が含まれている
- [ ] CI/CD パイプラインとデプロイ先が整合している
- [ ] `docs/architecture.md` にインフラ構成が記載されている
