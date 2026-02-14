---
description: アクセシビリティ監査をサブエージェントで実行
---

# アクセシビリティ監査

引数: `/audit-a11y [対象パス]`

## 手順

1. `.claude/agents/a11y-auditor.md` を読み込む
2. 対象ファイル数に応じてエージェントを起動:

### 10件以下: 1エージェント

```
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "a11y-auditor: アクセシビリティ監査",
  prompt: `
    .claude/agents/a11y-auditor.md を読み込み、ワークフローに従って監査してください。
    対象: $ARGUMENTS (指定なしの場合は全UIファイル)
  `
})
```

### 10件超: 3エージェント並行

- エージェント1: `src/app/` 配下
- エージェント2: `src/features/**/components/` 配下
- エージェント3: `src/components/` 配下

3. 結果を統合してユーザーに報告
