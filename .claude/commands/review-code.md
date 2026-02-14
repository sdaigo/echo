---
description: コードレビューをサブエージェントチームで並行実行
---

# コードレビュー

引数: `/review-code [対象パス|--staged]`

## 手順

1. `.claude/rules/agents.md` の委譲ルールを確認
2. 以下の3エージェントを**並行起動**:

### エージェント1: code-reviewer

```
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "code-reviewer: 品質レビュー",
  prompt: `
    .claude/agents/code-reviewer.md を読み込み、ワークフローに従ってレビューしてください。
    対象: $ARGUMENTS
  `
})
```

### エージェント2: security-reviewer

```
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "security-reviewer: セキュリティレビュー",
  prompt: `
    .claude/agents/security-reviewer.md を読み込み、ワークフローに従ってレビューしてください。
    対象: $ARGUMENTS
  `
})
```

### エージェント3: a11y-auditor (UI変更がある場合のみ)

```
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "a11y-auditor: アクセシビリティ監査",
  prompt: `
    .claude/agents/a11y-auditor.md を読み込み、ワークフローに従って監査してください。
    対象: $ARGUMENTS
  `
})
```

3. 全エージェントの結果を統合してユーザーに報告
