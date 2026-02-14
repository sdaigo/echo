# テスト原則

プロジェクト共通のテスト原則。ツール固有の設定は `docs/development-guidelines.md` を参照。

## TDD (テスト駆動開発)

新機能の開発はTDDで進める:

1. **Red**: 失敗するテストを書く
2. **Green**: テストを通す最小限のコードを書く
3. **Refactor**: コードを整理する

## カバレッジ目標

| 種別 | 対象 | カバレッジ |
|:---|:---|:---|
| ユニットテスト | サービスレイヤー、ユーティリティ関数 | 80%以上 |
| 統合テスト | API → Service → DB | 主要フローをカバー |
| E2Eテスト | ユーザーシナリオ全体 | 主要フローをカバー |

## テスト命名

`describe` + `it` で自然な文として読める形式にする:

```typescript
describe("ServiceName", () => {
  describe("methodName", () => {
    it("条件を満たす場合に期待する結果を返す", async () => {
      // ...
    })
  })
})
```

## Arrange-Act-Assert

テストは3つのセクションで構成する:

```typescript
it("条件に一致する要素を返す", () => {
  // Arrange: テストデータを準備
  const items = [{ id: "1", name: "A" }, { id: "2", name: "B" }] as const

  // Act: テスト対象を実行
  const result = findItem(items, "1")

  // Assert: 結果を検証
  expect(result?.name).toBe("A")
})
```

## モック・スタブの原則

- 外部依存（API、DB、ストレージ）は必ずモック化
- ビジネスロジック（サービスレイヤー）は実装を使用
- モックは専用ディレクトリに集約する
- テスト間でモックの状態が漏れないようにする
