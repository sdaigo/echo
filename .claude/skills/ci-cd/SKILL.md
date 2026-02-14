---
name: ci-cd
description: GitHub Actions CI/CDワークフローの生成・管理。PR検証パイプライン、デプロイパイプラインの構築時に使用する。
user-invocable: false
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# CI/CD Pipeline スキル

GitHub Actions を使用した CI/CD パイプラインの設計・生成を支援するスキルです。

## 使用タイミング

- CI/CD パイプラインの新規構築
- 既存ワークフローの修正・拡張
- デプロイ自動化の設定

## 前提条件

以下のドキュメントを読み込む:

- `docs/architecture.md` - デプロイ戦略、インフラ構成
- `docs/development-guidelines.md` - テスト・Lint の実行方法
- `docs/project-structure.md` - ビルド成果物の構成

## ファイル配置

```text
.github/
├── workflows/
│   ├── ci.yml              # PR検証パイプライン
│   ├── deploy-staging.yml  # ステージングデプロイ
│   └── deploy-production.yml # 本番デプロイ
└── actions/
    └── setup/
        └── action.yml      # 共通セットアップ（再利用可能）
```

## ワークフローテンプレート

### 1. 共通セットアップ（Composite Action）

```yaml
# .github/actions/setup/action.yml
name: "Setup"
description: "Bun + 依存関係のセットアップ"
runs:
  using: "composite"
  steps:
    - uses: oven-sh/setup-bun@v2
      with:
        bun-version: latest
    - name: Install dependencies
      shell: bash
      run: bun install --frozen-lockfile
```

### 2. PR検証パイプライン（ci.yml）

PRが作成・更新されたときに自動実行する:

```yaml
name: CI

on:
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup
      - run: bunx biome check .

  typecheck:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup
      - run: bunx tsc --noEmit

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup
      - run: bunx vitest run --coverage
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup
      - run: bun run build
```

### 3. ステージングデプロイ（deploy-staging.yml）

main ブランチへのマージで自動デプロイ:

```yaml
name: Deploy Staging

on:
  push:
    branches: [main]

concurrency:
  group: deploy-staging
  cancel-in-progress: false

jobs:
  deploy:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup
      - run: bun run build
      - name: Deploy
        run: |
          # デプロイ先に応じたコマンドに置き換える
          # Vercel: bunx vercel deploy --prebuilt
          # Cloudflare: bunx wrangler pages deploy
          echo "Deploy command here"
        env:
          DEPLOY_TOKEN: ${{ secrets.STAGING_DEPLOY_TOKEN }}
```

### 4. 本番デプロイ（deploy-production.yml）

手動トリガー + 承認フロー:

```yaml
name: Deploy Production

on:
  workflow_dispatch:
    inputs:
      ref:
        description: "デプロイするブランチまたはタグ"
        required: true
        default: main

concurrency:
  group: deploy-production
  cancel-in-progress: false

jobs:
  verify:
    name: Pre-deploy Verification
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.ref }}
      - uses: ./.github/actions/setup
      - run: bunx biome check .
      - run: bunx tsc --noEmit
      - run: bunx vitest run
      - run: bun run build

  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [verify]
    environment: production  # GitHub Environment の承認ゲートを使用
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.ref }}
      - uses: ./.github/actions/setup
      - run: bun run build
      - name: Deploy
        run: |
          # デプロイ先に応じたコマンドに置き換える
          echo "Deploy command here"
        env:
          DEPLOY_TOKEN: ${{ secrets.PRODUCTION_DEPLOY_TOKEN }}
```

## 作成手順

### 1. プロジェクト構成の確認

以下を確認してワークフローをカスタマイズする:

- `package.json` の `scripts` セクション（ビルドコマンド）
- テストフレームワークの設定（vitest.config.ts 等）
- Biome の設定（biome.json）
- デプロイ先のプラットフォーム

### 2. 共通セットアップの作成

`.github/actions/setup/action.yml` を作成する。キャッシュやBunバージョンはプロジェクトに合わせて調整する。

### 3. PR検証パイプラインの作成

`.github/workflows/ci.yml` を作成する。ジョブは並列実行を基本とし、build のみ他ジョブ完了後に実行する。

### 4. デプロイパイプラインの作成

デプロイ先に応じて staging / production ワークフローを作成する:

| デプロイ先 | デプロイコマンド |
|:---|:---|
| Vercel | `bunx vercel deploy --prebuilt --token=$VERCEL_TOKEN` |
| Cloudflare Pages | `bunx wrangler pages deploy ./out --project-name=$PROJECT` |
| Fly.io | `flyctl deploy --image` |

### 5. GitHub Secrets の設定

ワークフローで使用するシークレットをユーザーに案内する:

```text
以下のシークレットを GitHub リポジトリの Settings > Secrets に設定してください:

- STAGING_DEPLOY_TOKEN: ステージング環境のデプロイトークン
- PRODUCTION_DEPLOY_TOKEN: 本番環境のデプロイトークン
- [その他プロジェクト固有のシークレット]
```

### 6. GitHub Environments の設定

本番デプロイに承認ゲートを設けるため、以下を案内する:

```text
GitHub リポジトリの Settings > Environments で以下を設定してください:

1. "staging" 環境を作成
2. "production" 環境を作成し、Required reviewers を有効化
```

## カスタマイズガイド

### E2Eテストの追加

```yaml
e2e:
  name: E2E Test
  runs-on: ubuntu-latest
  needs: [build]
  steps:
    - uses: actions/checkout@v4
    - uses: ./.github/actions/setup
    - name: Install Playwright
      run: bunx playwright install --with-deps chromium
    - run: bun run build
    - run: bunx playwright test
```

### DB マイグレーションの追加

```yaml
- name: Run migrations
  run: bun drizzle-kit push
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

### Slack 通知の追加

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    fields: repo,message,commit,author
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## チェックリスト

ワークフロー作成後に確認:

- [ ] Bun のセットアップが `oven-sh/setup-bun@v2` を使用している
- [ ] `bun install --frozen-lockfile` で依存関係をインストールしている
- [ ] Lint / Type Check / Test / Build が全て含まれている
- [ ] PR検証ジョブが並列実行されている
- [ ] concurrency 設定で不要な同時実行を防いでいる
- [ ] 本番デプロイに `environment: production` の承認ゲートがある
- [ ] シークレットがハードコードされていない
- [ ] デプロイコマンドがプロジェクトのデプロイ先に合っている
