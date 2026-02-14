---
name: lofi-wireframer
description: 要求仕様から低忠実度ワイヤーフレームと画面遷移図を生成する。
user-invocable: false
allowed-tools: Read, Write
---

# Lo-Fi ワイヤーフレーマースキル

要求仕様から低忠実度ワイヤーフレームと画面遷移図を生成する。

## 前提ドキュメント

- `.steering/[日付]-[機能名]/requirements.md`（必須）
- `.steering/[日付]-[機能名]/design.md`（必須）

## 出力先

- `.steering/[日付]-[機能名]/prototypes/userflow.md`
- `.steering/[日付]-[機能名]/prototypes/wireframe.excalidraw`

## 動作フロー

1. 要求仕様を読み込み、必要な画面と要素を特定する
2. ユーザーの行動フローを **Mermaid (graph TD)** 形式で記述し、`userflow.md` として保存する
3. 各主要画面のレイアウトを **ExcalidrawのJSONスキーマに従い** 作成し、`wireframe.excalidraw` として保存する
4. 要求事項の漏れがないかチェックを行う

## ユーザの行動フローの凡例

- アクション: 円 - ユーザが取るべき行動
- スクリーン: 矩形 - ユーザが見ている画面
- 意思決定: 菱形 - ユーザが考えるべきこと

## 遵守事項

- 装飾は不要。要素の配置と情報の優先順位に集中すること
- 生成後、ユーザビリティ・ヒューリスティクス等の観点から改善案を2点提示すること
- 承認を得るまで、React等のコード実装には絶対に進まないこと
