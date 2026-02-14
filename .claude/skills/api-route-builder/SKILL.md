---
name: api-route-builder
description: Next.js Route Handler + zodバリデーション + 認証ミドルウェアのAPIルート生成。API作成時に使用する。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# API Route Builder スキル

プロジェクトのレイヤードアーキテクチャに準拠したNext.js API Route Handlerを生成するスキルです。

## 使用タイミング

- 新しいAPIエンドポイントの作成
- 既存APIの修正・拡張
- zodバリデーションスキーマの作成

## 前提条件

以下のドキュメントを読み込む:

- `docs/functional-design.md` - API設計（リクエスト/レスポンス定義）
- `docs/architecture.md` - レイヤードアーキテクチャ、セキュリティ
- `docs/project-structure.md` - ファイル配置ルール
- `docs/development-guidelines.md` - エラーハンドリング、コーディング規約

## ファイル配置

```text
src/app/api/
├── auth/[...all]/route.ts         # 認証プロバイダ
├── items/
│   ├── route.ts                   # POST, GET /api/items
│   └── [id]/route.ts             # PUT, DELETE /api/items/:id
└── organizations/
    ├── route.ts                   # POST /api/organizations
    └── [orgId]/
        ├── members/route.ts       # POST /api/organizations/:orgId/members
        └── settings/route.ts      # GET /api/organizations/:orgId/settings
```

## API Route Handler テンプレート

### 基本パターン

```typescript
import { type NextRequest, NextResponse } from "next/server"
import { z } from "zod"
import { AppError } from "@/lib/errors"
import { getAuthSession } from "@/features/auth/lib/auth-server"

// zodスキーマは lib/validations/ に配置
import { createEventSchema } from "@/lib/validations/event-schema"

// サービスレイヤーを呼び出し
import { createEvent } from "@/features/events/services/event-service"

export async function POST(request: NextRequest): Promise<NextResponse> {
  try {
    // 1. 認証チェック
    const session = await getAuthSession()
    if (!session) {
      return NextResponse.json(
        { code: "UNAUTHORIZED", message: "認証が必要です" },
        { status: 401 },
      )
    }

    // 2. 入力バリデーション
    const body: unknown = await request.json()
    const validated = createEventSchema.parse(body)

    // 3. サービスレイヤー呼び出し
    const result = await createEvent({
      ...validated,
      userId: session.user.id,
    })

    // 4. レスポンス
    return NextResponse.json(result, { status: 201 })
  } catch (error) {
    // 5. エラーハンドリング
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { code: "VALIDATION_ERROR", errors: error.flatten() },
        { status: 400 },
      )
    }
    if (error instanceof AppError) {
      return NextResponse.json(
        { code: error.code, message: error.message },
        { status: error.statusCode },
      )
    }
    console.error("Unexpected error:", error)
    return NextResponse.json(
      { code: "INTERNAL_ERROR", message: "サーバーエラーが発生しました" },
      { status: 500 },
    )
  }
}
```

## 作成手順

### 1. API仕様の確認

`docs/functional-design.md` から対象APIのリクエスト/レスポンス定義を読み込む。

### 2. zodスキーマの作成

`src/lib/validations/[リソース名]-schema.ts` にバリデーションスキーマを定義:

```typescript
import { z } from "zod"

export const createEventSchema = z.object({
  childId: z.string().uuid().optional(),
  title: z.string().min(1).max(100),
  startAt: z.string().datetime(),
  endAt: z.string().datetime().optional(),
  isAllDay: z.boolean(),
  location: z.string().max(100).optional(),
  items: z.array(z.string().max(50)).max(30).optional(),
})

export type CreateEventInput = z.infer<typeof createEventSchema>
```

### 3. Route Handler の作成

`src/app/api/[リソース名]/route.ts` に上記テンプレートに従って実装する。

### 4. サービスレイヤーの確認

Route Handlerからはサービスレイヤーのみを呼び出す。ビジネスロジックをRoute Handlerに書かない。

```text
Route Handler → Service → DB / External API
```

### 5. テストの作成

Route Handlerのユニットテストではなく、サービスレイヤーのテストを優先する。Route Handlerは統合テストでカバーする。

## チェックリスト

Route Handler作成後に確認:

- [ ] 認証チェックが含まれている
- [ ] zodスキーマでリクエストボディを検証している
- [ ] テナント/組織ベースの認可チェックがある（該当する場合）
- [ ] エラーハンドリングが統一パターンに従っている
- [ ] レスポンスのHTTPステータスコードが正しい
- [ ] `docs/functional-design.md` のAPI定義と一致している
- [ ] サービスレイヤーのみを呼び出している（DBに直接アクセスしていない）
- [ ] 内部エラーの詳細をクライアントに露出していない

## レート制限

以下のレート制限を実装する（ミドルウェアまたはRoute Handler内）:

| エンドポイント | 制限 |
|:---|:---|
| API全体 | 100 req/min/user |
| POST /api/extractions | 10 req/min/user |
| POST /api/images | 20 req/min/user |
