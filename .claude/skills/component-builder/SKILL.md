---
name: component-builder
description: shadcn/uiベースのReactコンポーネント生成。WCAG 2.1 AA準拠のアクセシブルなUIコンポーネントを作成する。
user-invocable: false
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Component Builder スキル

プロジェクトのデザインシステムとアクセシビリティ要件に準拠したReactコンポーネントを生成するスキルです。

## 使用タイミング

- 新しいUIコンポーネントの作成
- 既存コンポーネントの修正・拡張
- shadcn/uiコンポーネントの追加

## 前提条件

以下のドキュメントを読み込む:

- `docs/project-structure.md` - コンポーネントの配置ルール、命名規則
- `docs/development-guidelines.md` - コーディング規約、Props型の命名
- `docs/functional-design.md` - 画面一覧、UX設計、カラーコーディング

## コンポーネント配置ルール

### 判断基準

```text
特定の機能に閉じたUI？ → src/features/[機能名]/components/
複数機能から使われる汎用UI？ → src/components/ui/ または src/components/layout/
ページ / レイアウト？ → src/app/[ルート]/
```

### ファイル命名

- kebab-case: `item-card.tsx`, `login-form.tsx`
- テスト: `item-card.test.tsx`（同階層に配置）

## コンポーネント実装パターン

### 基本構造

```typescript
"use client" // インタラクションがある場合のみ

import type { ReactNode } from "react"

type ItemCardProps = {
  readonly title: string
  readonly description?: string
  readonly status?: string
  readonly onPress?: () => void
}

export function ItemCard({
  title,
  description,
  status,
  onPress,
}: ItemCardProps): ReactNode {
  return (
    // ...
  )
}
```

### ルール

- `"use client"` はインタラクション（useState, useEffect, イベントハンドラ）がある場合のみ
- Props型は `[コンポーネント名]Props` で命名する
- Props は `readonly` を付ける
- named export のみ（デフォルトエクスポート禁止、page/layout例外）
- 戻り値型を `ReactNode` で明示する

### shadcn/ui コンポーネントの追加

```bash
bunx shadcn@latest add [コンポーネント名]
```

追加先: `src/components/ui/`

利用可能なコンポーネント: button, card, dialog, input, label, select, skeleton, toast 等

## アクセシビリティ必須要件（WCAG 2.1 AA）

全コンポーネントで以下を満たすこと:

### インタラクティブ要素

- [ ] `role` 属性が適切に設定されている
- [ ] `aria-label` または `aria-labelledby` がある
- [ ] フォーカス可能でキーボード操作ができる
- [ ] フォーカスインジケータが視認できる

### タッチターゲット

- [ ] 最小サイズ 44x44px
- [ ] Tailwindで `min-h-11 min-w-11`（44px = 11 * 4px）

### フォーム要素

- [ ] `<label>` が `htmlFor` で紐付いている
- [ ] エラーメッセージが `aria-describedby` で紐付いている
- [ ] 必須フィールドに `aria-required="true"`

### 画像

- [ ] `alt` 属性がある（装飾画像は `alt=""`）

### カラー

- [ ] テキストのコントラスト比 4.5:1 以上（通常テキスト）
- [ ] 大きなテキストのコントラスト比 3:1 以上
- [ ] 色だけに依存した情報伝達がない

## テスト

コンポーネント作成時にテストファイルも同時に作成する:

```typescript
// item-card.test.tsx
import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"
import { ItemCard } from "./item-card"

describe("ItemCard", () => {
  it("タイトルが表示される", () => {
    render(<ItemCard title="サンプルアイテム" />)
    expect(screen.getByText("サンプルアイテム")).toBeInTheDocument()
  })

  it("アクセシビリティ: カードにrole属性がある", () => {
    // ...
  })
})
```

## モバイルファースト

全コンポーネントはモバイルファーストで設計する:

- 最小画面幅 320px（iPhone SE）対応
- Tailwind CSSのレスポンシブプレフィックス: `sm:`, `md:`, `lg:`
- 片手操作で主要操作が完結する配置
