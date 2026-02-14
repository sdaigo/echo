---
name: db-migration
description: Drizzle ORMスキーマ変更・マイグレーション管理を行う。DBスキーマ作成・変更時に使用する。
user-invocable: false
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# DB Migration スキル

Drizzle ORMを使用したデータベーススキーマの定義、マイグレーション生成、適用を管理するスキルです。

## 使用タイミング

- 新しいテーブルの作成
- 既存テーブルへのカラム追加・変更
- インデックスの追加
- RLSポリシーの設定
- マイグレーションの生成と適用

## 前提条件

以下のドキュメントを読み込んでからスキーマ定義を行う:

- `docs/functional-design.md` - データモデル定義（エンティティ、フィールド、制約）
- `docs/architecture.md` - データ永続化戦略、セキュリティ（RLS）
- `docs/project-structure.md` - `src/db/` のファイル配置ルール
- `docs/glossary.md` - エンティティ名の英語表記

## スキーマファイルの配置

```text
src/db/
├── schema/               # テーブル定義ファイルを配置
├── migrations/           # Drizzle Kit マイグレーションファイル
├── index.ts              # DB接続 (Drizzle + PostgreSQL)
└── seed.ts               # 開発用シードデータ
```

## スキーマ定義ルール

### 共通フィールド

全テーブルに以下のパターンを適用:

```typescript
import { pgTable, uuid, timestamp } from "drizzle-orm/pg-core"

// UUID主キー
id: uuid("id").primaryKey().defaultRandom()

// タイムスタンプ（作成・更新がある場合）
createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow()
updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow()
```

### 命名規則

| 対象 | TypeScript | DB カラム名 |
|:---|:---|:---|
| テーブル名 | PascalCase複数形 (`users`) | snake_case複数形 (`users`) |
| カラム名 | camelCase (`tenantId`) | snake_case (`tenant_id`) |
| インデックス名 | - | `idx_[テーブル]_[カラム]` |
| 外部キー名 | - | `fk_[テーブル]_[参照テーブル]` |

### 外部キーの定義

```typescript
import { pgTable, uuid } from "drizzle-orm/pg-core"
import { tenants } from "./tenants"

tenantId: uuid("tenant_id")
  .notNull()
  .references(() => tenants.id, { onDelete: "cascade" })
```

### インデックス

`docs/architecture.md` のスケーラビリティ設計に基づき、以下のインデックスを定義:

- `resources`: `(tenant_id, created_at)` 複合インデックス
- `members`: `(tenant_id)` インデックス

## 実行手順

### 新規テーブル作成

1. `docs/functional-design.md` のデータモデル定義を読み込む
2. `src/db/schema/[テーブル名].ts` にDrizzleスキーマを定義する
3. `src/db/schema/index.ts` にexportを追加する
4. マイグレーションを生成する:
   ```bash
   bun drizzle-kit generate
   ```
5. ローカルDBに適用する:
   ```bash
   bun drizzle-kit push
   ```
6. 型が正しく推論されることを確認する

### 既存テーブル変更

1. 変更対象の `src/db/schema/[テーブル名].ts` を読み込む
2. 変更を反映する
3. マイグレーションを生成する:
   ```bash
   bun drizzle-kit generate
   ```
4. 生成されたSQLマイグレーションファイルを確認する
5. データ損失がないか確認する（カラム削除、型変更等に注意）
6. ローカルDBに適用する:
   ```bash
   bun drizzle-kit push
   ```

### RLSポリシー設定

Supabaseダッシュボードまたは生SQLで設定する。全テーブルで以下のパターン:

```sql
-- tenantIdベースのRLS
ALTER TABLE [テーブル名] ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tenant_access" ON [テーブル名]
  USING (tenant_id IN (
    SELECT tenant_id FROM tenant_members
    WHERE user_id = auth.uid()
  ));
```

## 検証チェックリスト

スキーマ変更後に必ず確認する:

- [ ] `docs/functional-design.md` のデータモデル定義と一致しているか
- [ ] 全フィールドの型・制約が正しいか
- [ ] 外部キーのonDelete戦略が適切か（cascade / set null / restrict）
- [ ] 必要なインデックスが定義されているか
- [ ] TypeScript型が正しく推論されるか
- [ ] マイグレーションSQLにデータ損失リスクがないか
- [ ] `bun drizzle-kit push` が正常に完了するか

## シードデータ

開発用のテストデータを `src/db/seed.ts` で管理する:

```bash
bun db:seed
```

シードデータは `docs/functional-design.md` のペルソナに基づいて作成する。
