# Claude Code Development Template

設計と実装を意図的に分離し、ユーザー承認を間に挟む人間中心設計のワークフローテンプレート。

## ワークフロー

```
/setup              プロジェクト基盤の構築（docs/ の永続ドキュメント）
    |
/setup-infra        インフラ構成設計 + CI/CDパイプライン生成
    |
/feature-design     要件定義 + UX設計 + UXレビュー + ユーザー承認
    |
/feature-implement  承認済み設計に基づく実装 + 自動コードレビュー
    |
/pre-deploy         デプロイ前ゲートチェック（テスト・ビルド・セキュリティ）
```

## 構成

```
.claude/
  agents/          専門家エージェント（Task ツールで起動）
  rules/common/    汎用ルール（自動読み込み）
  commands/        スラッシュコマンド
  hooks/           ツール実行後の自動処理
  skills/          対話的ガイド（メインコンテキストに読み込み）
  settings.json    権限・フック設定
```

## エージェント

`.claude/agents/` に定義。条件を満たすと自動起動（PROACTIVE）する。

| Agent | Model | 自動起動条件 |
|:---|:---|:---|
| planner | opus | `/feature-design` 内部で tasklist.md 生成時 |
| ux-reviewer | sonnet | design.md 作成直後 |
| code-reviewer | sonnet | コード変更直後 |
| security-reviewer | sonnet | コード変更直後（code-reviewer と並行） |
| test-runner | haiku | フェーズ完了時 |
| a11y-auditor | sonnet | UI コンポーネント実装直後 |
| db-reviewer | sonnet | DB スキーマ変更直後 |

エージェントはプロジェクト固有の記述を持たず、`docs/` や `package.json` から動的に検出する。

## ルール

`.claude/rules/common/` に配置。Claude Code が自動的に読み込む。

| ファイル | 内容 |
|:---|:---|
| `workflow.md` | Do's/Don'ts、成果物レビュー、承認フロー |
| `coding-style.md` | 命名規則、型安全、関数設計、Biome 必須 |
| `testing.md` | TDD、カバレッジ 80%+、AAA パターン |
| `git-workflow.md` | Conventional Commits、PR プロセス |
| `security.md` | OWASP Top 10、入力バリデーション |
| `agents.md` | エージェント委譲、並行実行パターン |

## コマンド

`.claude/commands/` に定義。`/コマンド名` で実行する。

| コマンド | 用途 |
|:---|:---|
| `/setup` | 初回セットアップ（docs/ に 6 ファイル生成） |
| `/setup-infra` | インフラ構成設計 + CI/CD パイプライン生成 |
| `/feature-design` | 機能設計（.steering/ 生成 + UX レビュー） |
| `/feature-implement` | 承認済み設計に基づく実装開始 |
| `/checkpoint` | 作業状態の記録 |
| `/review-code` | code-reviewer + security-reviewer 並行実行 |
| `/run-tests` | test-runner 起動 |
| `/audit-a11y` | a11y-auditor 起動 |
| `/pre-deploy` | デプロイ前ゲートチェック |
| `/review-docs` | ドキュメントレビュー |

## スキル

`.claude/skills/` に定義。テンプレート同梱とプロジェクト追加に分類される。

### テンプレート同梱

| スキル | 用途 |
|:---|:---|
| steering | 作業計画・tasklist.md 管理 |
| prd-architect | プロダクト要求定義書の作成 |
| functional-design | 機能設計書の作成 |
| architecture-design | アーキテクチャ設計書の作成 |
| project-structure | プロジェクト構造定義の作成 |
| development-guidelines | 開発ガイドラインの作成 |
| glossary-creation | 用語集の作成 |
| lofi-wireframer | ワイヤーフレーム生成 |

### プロジェクト追加（例）

| スキル | 技術スタック |
|:---|:---|
| db-migration | Drizzle ORM / Supabase |
| component-builder | shadcn/ui / React |
| api-route-builder | Next.js Route Handler |
| ci-cd | GitHub Actions CI/CD |
| infra-guide | インフラ構成設計 |

## フック

`.claude/hooks/` に定義。ツール実行のライフサイクルイベントで自動実行される。

| フック | トリガー | 処理 |
|:---|:---|:---|
| `auto-format.sh` | Edit / Write 後 | Biome で自動フォーマット |

## 使い方

### 新規プロジェクトへの適用

1. `.claude/` ディレクトリをプロジェクトルートにコピー
2. `CLAUDE.md` をプロジェクトルートにコピーし、プロジェクト追加スキルを調整
3. `/setup` を実行して `docs/` の永続ドキュメントを対話的に作成
4. `/setup-infra` を実行してインフラ構成と CI/CD パイプラインを構築
5. `/feature-design [機能名]` で設計を開始

### 前提条件

- Bun（https://bun.sh）
- Biome（`bun add -D @biomejs/biome`）
- jq（フック内で JSON パースに使用）
