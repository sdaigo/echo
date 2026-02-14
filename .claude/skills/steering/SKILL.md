---
name: steering
description: 作業指示毎の作業計画、タスクリストをドキュメントに記録するためのスキル。ユーザーからの指示をトリガーとした作業計画時、検証時に読み込む。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

# Steering スキル

ステアリングファイル（`.steering/`）に基づいた機能設計を支援し、実装に必要なtasklist.md（進捗管理）を作成するスキルです。

## スキルの目的

- ステアリングファイル（requirements.md, design.md, tasklist.md）の作成支援
- 実装時にtasklist.mdに基づいた段階的な進捗管理

## モード指定

引数でモードを指定する:

- `Skill('steering', args: '計画')` → 計画モード
- `Skill('steering', args: '実装')` → 実装モード
- `Skill('steering', args: '振り返り')` → 振り返りモード

引数なしの場合は、現在の `.steering/` の状態から自動判定する:
- tasklist.md が未作成 → 計画モード
- 未完了タスクあり → 実装モード
- 全タスク完了済み → 振り返りモード

## モード一覧

1. **計画モード**: ステアリングファイルを作成する時
2. **実装モード**: tasklist.mdに従って実装する時
3. **振り返りモード**: 実装完了後の振り返りを記録する時

---

## 計画モード

### 目的

新しい機能や変更のためのステアリングファイルを作成します。

### 手順

#### 1. ステアリングディレクトリの作成

現在の日付を取得し、`.steering/[YYYYMMDD]-[機能名]/` の形式でディレクトリを作成する。

#### 2. 永続ドキュメントの確認

以下を全て読んで、プロジェクトの方針を理解する:

- `docs/product-requirements.md` - プロダクト要求定義書
- `docs/functional-design.md` - 機能設計書
- `docs/architecture.md` - アーキテクチャ設計書
- `docs/project-structure.md` - プロジェクト構造定義書
- `docs/development-guidelines.md` - 開発ガイドライン
- `docs/glossary.md` - 用語集

#### 3. テンプレートからファイル作成

以下のテンプレートを読み込み、プレースホルダーを具体的な内容に置き換えてファイルを作成:

- `.claude/skills/steering/templates/requirements.md` → `.steering/[日付]-[機能名]/requirements.md`
- `.claude/skills/steering/templates/design.md` → `.steering/[日付]-[機能名]/design.md`
- `.claude/skills/steering/templates/tasklist.md` → `.steering/[日付]-[機能名]/tasklist.md`

**重要**: ファイルを作成したらユーザーにレビューを依頼すること。ユーザーから明示的に承認がない限り次のステップには進まないこと。

---

## 実装モード

### 目的

tasklist.mdに従って実装を進め、進捗を**確実に**ドキュメントに記録します。

### タスク完了の原則

tasklist.mdに記載された全タスクが`[x]`になるまで作業を継続すること。以下はこの原則を支えるルールです。

#### 禁止事項

- tasklist.mdを見ずに実装を進める
- TaskCreate/TaskUpdateだけで進捗管理する（TaskCreate/TaskUpdateは補助、tasklist.mdが正式記録）
- 複数タスクをまとめて更新する（1タスクずつリアルタイムに更新する）
- 「時間の都合により」「別タスクとして実施予定」「実装が複雑すぎるため後回し」などの理由でタスクをスキップする
- 未完了タスク（`[ ]`）を残したまま作業を終了する

#### タスクが大きすぎる場合

1. タスクを小さなサブタスクに分割する
2. 分割したサブタスクをtasklist.mdに追加する
3. サブタスクを1つずつ完了させる

#### 技術的理由によるスキップ（唯一の例外）

以下の技術的理由に該当する場合のみスキップ可能:

- 方針の変更により、機能自体が不要になった
- 依存関係の変更により、タスクが実行不可能になった
- 上位の設計変更により、このタスクが無意味になった

スキップ手順:

1. tasklist.mdに技術的な理由を明記: `- [x] ~~タスク名~~（実装方針変更により不要: 具体的な技術的理由）`
2. 振り返りセクションに変更理由を詳細に記録

### 実装フロー

#### ステップ1: ドキュメント読み込み

```text
Read('.steering/[日付]-[機能名]/tasklist.md')
Read('.steering/[日付]-[機能名]/design.md')
Read('.steering/[日付]-[機能名]/prototypes/userflow.md')
Read('docs/development-guidelines.md')
Read('docs/project-structure.md')
```

全体のタスク構造を把握し、次に着手すべきタスクを特定する。
設計とユーザーフローを確認し、実装の全体像を理解する。
開発ガイドラインとプロジェクト構造を確認し、コーディング規約とファイル配置ルールを理解する。

#### ステップ2: TaskCreateでタスク管理開始

tasklist.mdの内容に基づいてTaskCreateツールでタスクリストを作成:

```text
TaskCreate({ subject: "タスク名", description: "詳細", activeForm: "タスク名を実装中" })
```

- これはClaude Code内部の補助的な進捗トラッキング
- **tasklist.mdが正式なドキュメント**

#### ステップ3: タスクループ（各タスクで繰り返す）

**3-1. 次のタスクを確認**

tasklist.mdを読み、次の未完了タスク（`[ ]`）を特定する。

**3-2. TaskUpdateでステータス更新**

```text
TaskUpdate({ taskId: "対象ID", status: "in_progress" })
```

注意: この時点では tasklist.md は `[ ]` のまま。`[x]` への更新はタスク完了時（ステップ3-7）に行う。

**3-3. 実装を実行**

`docs/development-guidelines.md` のコーディング規約に従って実装する。
`docs/project-structure.md` のファイル配置ルールに従ってファイルを作成する。

**3-4. テストを実行**

実装完了後、関連するテストを実行する:

```bash
# ユニットテスト（対象ファイル）
bunx vitest run [テスト対象パス]

# 型チェック
bunx tsc --noEmit

# Lint
bunx biome check [対象パス]
```

テストが失敗した場合は修正してから次に進む。

**3-5. PROACTIVE エージェント起動**

`.claude/rules/common/agents.md` の PROACTIVE 条件に従い、変更内容に応じてエージェントを自動起動する:

- コード変更後 → `code-reviewer` + `security-reviewer`（並行）
- UIコンポーネント実装後 → `a11y-auditor`
- DBスキーマ変更後 → `db-reviewer`

エージェントからの指摘があれば修正してからタスク完了に進む。

**3-6. タスク完了をtasklist.mdに記録（必須）**

実装・テスト完了後、Editツールでtasklist.mdを更新して完了を記録:

```text
old_string: "- [ ] StorageServiceを実装"
new_string: "- [x] StorageServiceを実装"
```

サブタスクがある場合はサブタスクも個別に更新する。

**3-7. TaskUpdateでもステータス更新**

```text
TaskUpdate({ taskId: "対象ID", status: "completed" })
```

**3-8. 次のタスクへ**

ステップ3-1に戻る。

#### ステップ4: フェーズ完了時の確認

各フェーズが完了したら:

1. tasklist.mdを読み込んで進捗確認
2. 全てのタスクが`[x]`になっているか確認
3. ユーザーに報告: 「フェーズNが完了しました。tasklist.mdの進捗を確認してください。」

#### ステップ5: 全タスク完了チェック（必須）

全フェーズの実装完了後、振り返りを書く前に必ず実行:

1. tasklist.mdを読み込む
2. 未完了タスク（`[ ]`）がないか確認
3. 未完了タスクが見つかった場合:
   - **パターンA**: ステップ3（タスクループ）に戻り、未完了タスクを実装する
   - **パターンB**: タスクが大きすぎる場合、サブタスクに分割してから実装する
   - **パターンC**: 技術的理由で不要になった場合のみ、理由を明記してスキップする
4. 全タスク完了を確認できた場合のみステップ6へ進む

#### ステップ6: 全タスク完了後

1. tasklist.mdの全タスクが`[x]`であることを最終確認する
2. 振り返りセクションをEditツールで更新する（振り返りモード参照）

### 実装中のセルフチェック

5タスクごとに以下を確認:

- tasklist.mdを最近更新したか？
- 進捗がドキュメントに反映されているか？（Read toolで確認）
- ユーザーがtasklist.mdを見て進捗が分かるか？

---

## 振り返りモード

### 目的

実装完了後、tasklist.mdに振り返りを記録します。

### 手順

1. tasklist.mdを読み込む
2. 振り返り内容を作成:
   - 実装完了日
   - 計画と実績の差分（計画と異なった点）
   - 学んだこと（技術的な学び、プロセス上の改善点）
   - 次回への改善提案
3. Editツールでtasklist.mdの「実装後の振り返り」セクションを更新
4. ユーザーに報告: 「振り返りをtasklist.mdに記録しました。内容を確認してください。」

---

## トラブルシューティング

### tasklist.mdの更新を忘れた場合

1. 即座にtasklist.mdを読み込む
2. 完了したタスクを特定し、全てEditツールで`[x]`に更新する
3. ユーザーに報告: 「tasklist.mdの更新が遅れていたため、現在の進捗を反映しました。」

### tasklist.mdと実装の乖離

1. Editツールで該当タスクに注釈を追加: `- [x] タスク名（実装方法を変更: 理由）`
2. 必要に応じて新しいタスクを追加
3. 設計の変更が大きい場合はdesign.mdも更新

---

## チェックリスト

### 実装前

- [ ] tasklist.mdを読み込んだか？
- [ ] development-guidelines.mdを読み込んだか？
- [ ] project-structure.mdを読み込んだか？
- [ ] 次のタスクを特定したか？

### 各タスク完了時

- [ ] Editツールでtasklist.mdを更新したか？
- [ ] テストを実行したか？
- [ ] TaskUpdateで補助トラッキングを更新したか？

### 全タスク完了後

- [ ] 全タスクが`[x]`か？
- [ ] 振り返りセクションを記録したか？
- [ ] ユーザーが見て進捗が分かる状態か？
