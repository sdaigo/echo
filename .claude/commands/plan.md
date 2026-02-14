---
description: plannerエージェントで実装計画を策定
---

# 実装計画

引数: `/plan [機能名や要求の説明]`

## 手順

1. plannerエージェントを起動:

```
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "planner: 実装計画策定",
  prompt: `
    .claude/agents/planner.md を読み込み、ワークフローに従って実装計画を策定してください。
    対象: $ARGUMENTS
  `
})
```

2. 計画結果をユーザーに報告
3. 承認後、`.steering/` にtasklist.mdとして保存するか確認
