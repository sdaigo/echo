---
description: インフラ構成の設計とCI/CDパイプラインを構築する
---

# インフラセットアップ

`/setup` 完了後に実行する。デプロイ先の選定、環境構成の設計、CI/CDパイプラインの生成を行う。

## 前提条件

- `/setup` が完了し、`docs/` 配下に永続ドキュメントが存在すること
- 特に `docs/architecture.md` と `docs/product-requirements.md` が必要

## ステップ1: インフラ構成の設計

`Skill('infra-guide')` を実行する。

infra-guide スキルに従い、以下を順に進める:

1. プロジェクトの要件整理（アプリ種別、DB、認証、ストレージ等）
2. プラットフォーム選定（比較表をユーザーに提示）
3. 構成パターンの提案
4. 環境構成の設計（local / preview / staging / production）
5. 監視・可観測性の設計

設計結果を `docs/architecture.md` のインフラセクションに追記する。

**ユーザーに確認を求め、承認されるまで次のステップに進まない。**

## ステップ2: CI/CD パイプラインの生成

`Skill('ci-cd')` を実行する。

ステップ1で決定したデプロイ先に基づき、ci-cd スキルに従ってワークフローを生成する:

1. 共通セットアップ（`.github/actions/setup/action.yml`）
2. PR検証パイプライン（`.github/workflows/ci.yml`）
3. ステージングデプロイ（`.github/workflows/deploy-staging.yml`）
4. 本番デプロイ（`.github/workflows/deploy-production.yml`）

デプロイコマンドはステップ1の選定結果に合わせてカスタマイズする。

## ステップ3: シークレットと環境の案内

ユーザーに以下の手動設定を案内する:

1. **GitHub Secrets**: デプロイトークン等の設定手順
2. **GitHub Environments**: staging / production 環境の作成と承認ゲートの設定
3. **環境変数**: `.env.example` のテンプレート作成（未作成の場合）

## 完了条件

以下が全て揃っていること:

```text
docs/architecture.md          # インフラセクションが追記されている
.github/actions/setup/action.yml
.github/workflows/ci.yml
.github/workflows/deploy-staging.yml
.github/workflows/deploy-production.yml
.env.example                   # 環境変数テンプレート（該当する場合）
```

完了後、以下を案内:

- `/feature-design [機能名]` で個別機能の設計を開始できる
- `/pre-deploy [staging|production]` でデプロイ前チェックを実行できる
