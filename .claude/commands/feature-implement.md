---
description: 承認済みの設計に基づき、tasklist.mdに従って実装を開始する
---

# 機能実装の開始

引数: `/feature-implement [ステアリングディレクトリパス]`

## 前提条件

- `/feature-design` で設計が完了し、ユーザーの承認を得ていること
- `.steering/[日付]-[機能名]/` に以下が存在すること:
  - `requirements.md` - 承認済みの要件
  - `design.md` - UXレビュー反映済みの設計
  - `tasklist.md` - planner が生成した詳細タスクリスト
  - `prototypes/` - ワイヤーフレームとユーザーフロー（UI実装の参考）

## ステップ1: 設計の読み込みと確認

1. 引数で指定されたステアリングディレクトリを特定する
   - パス指定なし → `.steering/` 内の最新ディレクトリを使用
2. `requirements.md`, `design.md`, `tasklist.md` を読み込む
3. タスクリストの全体像をユーザーに報告し、開始の確認を得る

## ステップ2: 実装モードで開始

`Skill('steering', args: '実装')` を実行する。

steeringスキルの実装モードに従い:
- tasklist.md の未完了タスクを順に実装
- 各タスク完了時に tasklist.md を更新
- 各タスクでPROACTIVEエージェントを自動起動（steering実装モード ステップ3-6参照）
- 5タスクごとにセルフチェック

## ステップ3: フェーズ完了時

各フェーズ完了時:
1. test-runner エージェントを起動してテスト実行:
   ```
   Task({
     subagent_type: "general-purpose",
     model: "haiku",
     description: "test-runner: フェーズ完了テスト",
     prompt: `
       .claude/agents/test-runner.md を読み込み、フルテストを実行してください。
       モード: --full
     `
   })
   ```
2. テスト失敗時はステップ2に戻り修正する。全テスト通過するまで次に進まない
3. tasklist.md の進捗をユーザーに報告
4. 次のフェーズへの承認を得る

## ステップ4: 全タスク完了

1. tasklist.md の全タスクが `[x]` であることを確認
2. test-runner エージェントを起動して最終テスト（上記と同じパターン）
3. `Skill('steering', args: '振り返り')` を実行し、振り返りを記録
4. ユーザーに完了を報告
