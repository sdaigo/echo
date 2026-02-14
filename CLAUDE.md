
# プロジェクトメモリ

## 設計思想

設計と実装を意図的に分離し、ユーザー承認を間に挟む人間中心設計のワークフロー。

```
/setup          プロジェクト基盤の構築（docs/ の永続ドキュメント）
    ↓
/feature-design 要件定義 + UX設計 + UXレビュー + ユーザー承認
    ↓
/feature-implement  承認済み設計に基づく実装 + 自動コードレビュー
```

## 開発ワークフロー

### 1. プロジェクト基盤（1回のみ）

`/setup` で永続ドキュメント（PRD、機能設計、アーキテクチャ等）を対話的に作成。

### 2. 設計フェーズ（機能ごと）

`/feature-design [機能名]` で `.steering/` に作業ドキュメントを生成:
- requirements.md → design.md → **ux-reviewer によるUXレビュー** → ユーザー承認 → tasklist.md

### 3. 実装フェーズ（機能ごと）

`/feature-implement` で承認済みの設計に基づき実装:
- tasklist.md に従って実装 → **code-reviewer + security-reviewer が自動起動** → テスト → 振り返り

## ディレクトリ構造

```
docs/                   永続ドキュメント（プロジェクト全体の設計）
  proposals/            下書き・アイデア・技術調査メモ
.steering/              作業単位のドキュメント（requirements, design, tasklist）
.claude/
  agents/               専門家エージェント定義（Taskツールで起動）
  rules/common/         汎用ルール（コーディング、テスト、Git、セキュリティ、ワークフロー）
  commands/             スラッシュコマンド（エージェント起動のオーケストレーター）
  skills/               スキル定義（メインコンテキストに読み込む対話的ガイド）
```

## ルール

`.claude/rules/common/` に汎用原則を定義（自動読み込み）:

| ファイル | 内容 |
|:---|:---|
| `workflow.md` | Do's/Don'ts、成果物レビュー、承認フロー |
| `coding-style.md` | 命名規則、型安全、関数設計、イミュータビリティ |
| `testing.md` | TDD、カバレッジ、AAA、モック原則 |
| `git-workflow.md` | ブランチ戦略、Conventional Commits、レビュー基準 |
| `security.md` | 入力バリデーション、認証・認可、OWASP Top 10 |
| `agents.md` | エージェント委譲、並行実行、オーケストレーション |

## エージェント

`.claude/agents/` に定義。委譲ルールは `.claude/rules/common/agents.md` を参照。

| Agent | Model | Purpose |
|:---|:---|:---|
| planner | opus | 実装計画・タスク分解 |
| ux-reviewer | sonnet | UXレビュー・ユーザビリティ評価 |
| code-reviewer | sonnet | コード品質・規約準拠 |
| security-reviewer | sonnet | セキュリティ脆弱性検出 |
| test-runner | haiku | テスト実行・結果分析 |
| a11y-auditor | sonnet | WCAG 2.1 AAアクセシビリティ監査 |
| db-reviewer | sonnet | DBスキーマ・アクセス制御・マイグレーション検証 |

## スキル

`.claude/skills/` に定義。テンプレート同梱とプロジェクト追加で分類。

### テンプレート同梱（プロジェクト非依存）

| スキル | 用途 |
|:---|:---|
| steering | 作業計画・tasklist.md管理（計画/実装/振り返りモード） |
| prd-architect | プロダクト要求定義書の作成 |
| functional-design | 機能設計書の作成 |
| architecture-design | アーキテクチャ設計書の作成 |
| project-structure | プロジェクト構造定義の作成 |
| development-guidelines | 開発ガイドラインの作成 |
| glossary-creation | 用語集の作成 |
| lofi-wireframer | ワイヤーフレーム・画面遷移図の生成 |

### プロジェクト追加（技術スタック依存）

| スキル | 技術スタック | 用途 |
|:---|:---|:---|
| db-migration | Drizzle ORM / Supabase | DBスキーマ・マイグレーション管理 |
| component-builder | shadcn/ui / React | UIコンポーネント生成 |
| api-route-builder | Next.js Route Handler | APIルート生成 |

プロジェクトの技術スタックに合わせて追加・差し替えする。

## プロジェクト固有の設定

- コーディング規約: `docs/development-guidelines.md`
- ファイル配置ルール: `docs/project-structure.md`
- 用語集: `docs/glossary.md`
