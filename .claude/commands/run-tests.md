---
description: テスト実行をサブエージェントで実行
---

# テスト実行

引数: `/run-tests [対象パス] [--full|--e2e|--coverage]`

## 手順

1. `.claude/agents/test-runner.md` を読み込む
2. Task ツールで test-runner エージェントを起動:

```
Task({
  subagent_type: "general-purpose",
  model: "haiku",
  description: "test-runner: テスト実行",
  prompt: `
    .claude/agents/test-runner.md を読み込み、ワークフローに従ってテストを実行してください。
    対象: $ARGUMENTS
  `
})
```

3. 結果をユーザーに報告
