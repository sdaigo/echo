---
description: 指定された機能の設計を開始し、.steering/ 内に作業用ドキュメントを生成する
---

# 新機能の設計開始

引数: `/feature-design [機能名]`

## ステップ1: 準備とコンテキスト設定

1. 現在のタスクコンテキストを確立する:
   - 機能名: `$ARGUMENTS`
   - 日付: `[現在の日付をYYYYMMDD形式で取得]`
   - ステアリングディレクトリパス: `.steering/[日付]-[機能名]/`
2. ステアリングディレクトリを作成する
3. 以下の3つの空ファイルを作成する:
   - `requirements.md`
   - `design.md`
   - `tasklist.md`

## ステップ2: プロジェクト理解

1. `CLAUDE.md` を読み、プロジェクトの全体像を把握する
2. `docs/` ディレクトリ内の永続ドキュメントを確認し、関連する設計思想やアーキテクチャを理解する

## ステップ3: 計画フェーズ（ステアリングファイルの生成）

1. `Skill('steering', args: '計画')` を実行し、requirements.md と design.md を生成する
2. ユーザーの承認を得る

## ステップ4: ワイヤーフレーム作成

design.md の承認後、`Skill('lofi-wireframer')` を実行してユーザーフローとワイヤーフレームを作成する:

- 出力先: `.steering/[日付]-[機能名]/prototypes/`
- requirements.md と design.md を入力として渡す
- ユーザーの承認を得る

## ステップ5: UXレビュー

ワイヤーフレームの承認後、ux-reviewer エージェントを起動してUX観点のレビューを行う:

```
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "ux-reviewer: 機能設計のUXレビュー",
  prompt: `
    .claude/agents/ux-reviewer.md を読み込み、ワークフローに従ってレビューしてください。
    対象:
    - .steering/[日付]-[機能名]/design.md
    - .steering/[日付]-[機能名]/prototypes/userflow.md
    - .steering/[日付]-[機能名]/prototypes/wireframe.excalidraw
  `
})
```

レビュー結果をユーザーに報告し、必要に応じて design.md やワイヤーフレームを修正する。

## ステップ6: タスクリスト生成

UXレビューの反映後、`Skill('steering', args: '計画')` で tasklist.md を詳細化する。

## 補足

このコマンドは **設計フェーズのみ** を実行する。
実装に進む場合は、ユーザーの承認後に `Skill('steering')` の **実装モード** を使用する。
