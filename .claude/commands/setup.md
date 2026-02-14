---
description: 初回セットアップ: 永続ドキュメントを対話的に作成する
---

# 初回プロジェクトセットアップ

プロジェクトの永続ドキュメント（`docs/`）を対話的に作成する。

## 前提

- `.claude/rules/common/` に汎用ルール（コーディング規約、テスト、Git、セキュリティ）が配置済み
- プロジェクト固有のガイドラインは `docs/development-guidelines.md` に記載し、`rules/common/` を拡張する形で構成する

## 環境チェック

以下のコマンドで必須ツールの存在を確認する。不足があればユーザーに通知し、インストールを案内する:

```bash
bun --version    # Bun（パッケージマネージャ・ランタイム）
jq --version     # jq（フック内のJSONパースに使用）
```

- **Bun**: https://bun.sh (`curl -fsSL https://bun.sh/install | bash`)
- **jq**: https://jqlang.github.io/jq/ (`brew install jq`)

全ツールが揃っていることを確認してから次に進む。

## 実行前の確認

`docs/proposals/` ディレクトリ内のファイルを確認する。

- ファイルが存在する場合: 内容を元にPRDを作成
- ファイルが存在しない場合: 対話形式でPRDを作成

## 手順

### ステップ0: インプットの読み込み

1. `docs/proposals/` 内のマークダウンファイルを全て読む
   - マークダウンファイルがあれば:
     - 内容を理解し、PRD作成の参考にする
     - 不明確な点があれば、ユーザーに確認を取る
   - マークダウンファイルがなければ:
     - ユーザと対話しながらアイデアを練る
     - 決定した内容を `docs/proposals/requirements.md` に記録する
2. ユーザーに確認を求め、**承認されるまで待機**
3. 修正の要求があれば修正し、再度確認を求める
4. **承認されるまで次のステップに進まない**

### ステップ1: PRD（プロダクト要求定義書）

1. **prd-architect** スキルをロード
2. `docs/proposals/` の内容を元に `docs/product-requirements.md` を作成
3. アイデアを具体化（ユーザーストーリー、受け入れ条件、非機能要件、成功指標）
4. ユーザーに確認を求め、**承認されるまで待機**

**以降のステップはPRDの内容を元に生成する。各ステップの完了後、ユーザーに確認を求め、承認を得てから次に進む。**

### ステップ2: 機能設計書

1. **functional-design** スキルをロード
2. `docs/product-requirements.md` を読む
3. テンプレートとガイドに従って `docs/functional-design.md` を作成
4. ユーザーに確認を求め、**承認されるまで次に進まない**

### ステップ3: アーキテクチャ設計書

1. **architecture-design** スキルをロード
2. 既存のドキュメントを読む
3. テンプレートとガイドに従って `docs/architecture.md` を作成
4. ユーザーに確認を求め、**承認されるまで次に進まない**

### ステップ4: プロジェクト構造

1. **project-structure** スキルをロード
2. 既存のドキュメントを読む
3. 要件と技術スタックに即してガイド（`guide.md`）を `.claude/skills/project-structure` に更新する（既存の場合はプロジェクト固有の情報で拡充）
4. テンプレートに従って `docs/project-structure.md` を作成
5. ユーザーに確認を求め、**承認されるまで次に進まない**

### ステップ5: 開発ガイドライン

1. **development-guidelines** スキルをロード
2. 既存のドキュメントと `.claude/rules/common/` の汎用ルールを読む
3. テンプレートに従って `docs/development-guidelines.md` を作成
   - **重要**: `rules/common/` に定義済みの汎用原則は重複させない
   - `docs/development-guidelines.md` にはプロジェクト固有の設定のみを記載する
   - 冒頭で `rules/common/` への参照を明記する
4. ユーザーに確認を求め、**承認されるまで次に進まない**

### ステップ6: 用語集

1. **glossary-creation** スキルをロード
2. 既存のドキュメントを読む
3. テンプレートに従って `docs/glossary.md` を作成
4. ユーザーに確認を求め、**承認されるまで次に進まない**

## 完了条件

6つの永続ドキュメントが全て作成されていること:

```text
docs/product-requirements.md
docs/functional-design.md
docs/architecture.md
docs/project-structure.md
docs/development-guidelines.md
docs/glossary.md
```

完了後、以下を案内:

- `rules/common/` の汎用ルールがベースとして適用される
- プロジェクト固有の技術スタックに応じて `.claude/skills/` にスキルを追加できる
- `/setup-infra` でインフラ構成と CI/CD パイプラインを構築できる
- `/feature-design` で個別機能の作業計画を開始できる
