# エージェント委譲ルール

## Available Agents

`.claude/agents/` に定義された専門家チーム。各エージェントの YAML Front Matter で `name`, `description`, `tools`, `model` を確認する。

### 標準エージェント構成

| Agent | Model | Purpose | When to Use |
|:---|:---|:---|:---|
| planner | opus | 実装計画・タスク分解 | `/feature-design` 内部で tasklist.md 生成時 |
| ux-reviewer | sonnet | UXレビュー・ユーザビリティ評価 | 機能設計時、UIフロー設計時 |
| code-reviewer | sonnet | コード品質・規約準拠 | コード変更後 |
| security-reviewer | sonnet | セキュリティ脆弱性検出 | 認証/API/入力処理コード変更後 |
| test-runner | haiku | テスト実行・結果分析 | 実装完了後、コミット前 |
| a11y-auditor | sonnet | WCAG 2.1 AAアクセシビリティ監査 | UIコンポーネント実装後 |
| db-reviewer | sonnet | DBスキーマ・アクセス制御・マイグレーション検証 | DBスキーマ変更後 |

プロジェクトの要件に応じてエージェントを追加・削除してよい。

### モデル選択基準

| Model | 用途 | コスト |
|:---|:---|:---|
| opus | 複雑なアーキテクチャ推論、微妙な設計判断 | 高 |
| sonnet | 一般的なコーディング作業（全体の80%） | 中 |
| haiku | 単純なタスク、ファイル読み込み、テスト実行 | 低 |

## Immediate Agent Usage (PROACTIVE)

ユーザーの指示がなくても、以下の条件で自動的にエージェントを起動する:

1. **機能設計（design.md）を作成した直後** → `ux-reviewer` を起動
2. **コードを書いた/変更した直後** → `code-reviewer` + `security-reviewer` を並行起動
3. **UIコンポーネントを実装した直後** → `a11y-auditor` を起動
4. **DBスキーマを変更した直後** → `db-reviewer` を起動
5. **フェーズ完了時** → `test-runner` を `--full` モードで起動

**注意**: `planner` はPROACTIVEではなく、`/feature-design` 内部で tasklist.md 生成時にのみ使用される。ユーザーが直接呼び出すことはない。

## Agent Spawning Pattern

エージェントを起動する際は、Task ツールで以下のように呼び出す:

```
Task({
  subagent_type: "general-purpose",
  model: [エージェントのmodel値],
  description: "[エージェント名]: [簡潔な説明]",
  prompt: `
    まず .claude/agents/[エージェント名].md を読み込み、
    あなたの役割、ワークフロー、出力フォーマットを理解してください。

    次に、以下のタスクを実行してください:
    [具体的な指示]

    対象: [ファイルパスまたは範囲]
  `
})
```

## Parallel Execution

独立したレビューは必ず並行実行する:

```
# GOOD: 並行実行
1つのメッセージで以下を同時起動:
- code-reviewer: コード品質チェック
- security-reviewer: セキュリティチェック

# BAD: 逐次実行
code-reviewer を待ってから security-reviewer を起動
```

## Handoff Document

エージェントの結果を次のエージェントに引き継ぐ場合:

```markdown
## HANDOFF: [前エージェント] -> [次エージェント]

### Context
[何を行ったかの要約]

### Findings
[発見事項]

### Files Modified
[変更されたファイル]

### Open Questions
[未解決事項]

### Recommendations
[次エージェントへの推奨事項]
```

## Orchestration Patterns

### 新機能実装フロー

```
/feature-design
  steering(計画) → lofi-wireframer → ux-reviewer → planner(tasklist生成)
/feature-implement
  [実装] → code-reviewer + security-reviewer (並行)
         → a11y-auditor (UI変更あれば)
         → test-runner
```

### DBスキーマ変更フロー

```
[スキーマ変更] → db-reviewer → test-runner
```

### コミット前チェック

```
code-reviewer + security-reviewer + a11y-auditor (並行) → test-runner --full
```
