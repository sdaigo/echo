# コーディング規約

プロジェクト共通のコーディング原則。プロジェクト固有の設定は `docs/development-guidelines.md` を参照。

## フォーマッター

**Biome** (Linter + Formatter 統合) を必須ツールとして使用する。

- Edit/Write 後に PostToolUse hook で自動実行される（`.claude/hooks/auto-format.sh`）
- プロジェクト固有のBiome設定は `biome.json` に記載する
- biome.json が未作成の場合はデフォルト設定で動作する

## 命名規則

| 種別 | 規則 | 例 |
|:---|:---|:---|
| ローカル変数 | camelCase | `itemList`, `isLoading` |
| 定数 | UPPER_SNAKE_CASE | `MAX_FILE_SIZE`, `DEFAULT_LIMIT` |
| 関数 | camelCase (動詞始まり) | `createItem()`, `validateInput()` |
| Boolean変数 | `is`/`has`/`can`/`should` 接頭辞 | `isVisible`, `hasPermission` |
| イベントハンドラ | `handle` + イベント名 | `handleSubmit`, `handleClick` |
| コールバックprop | `on` + イベント名 | `onChange`, `onSubmit` |
| 型 | PascalCase | `UserData`, `ApiResponse` |
| Props型 | コンポーネント名 + `Props` | `ButtonProps`, `FormProps` |
| Enumライクな定数 | `as const` オブジェクト | `STATUS`, `ROLES` |

## 型安全

- `any` 禁止。代わりに `unknown` + 型ガードで絞り込む
- 型アサーション (`as`) は最小限。使用時はコメントで理由を記載
- 関数の戻り値型は明示する（推論に頼らない）
- `interface` より `type` を優先（union/intersection型との一貫性）

## 関数設計

- 関数は小さく保つ（20行以下を目安、上限50行）
- 副作用を持つ関数と純粋関数を明確に分離
- 引数は3つ以下。超える場合はオブジェクト引数にする
- early returnで深いネストを回避

## イミュータビリティ

- オブジェクトや配列を直接変更しない
- `readonly` 修飾子を活用する
- スプレッド構文や `Array.map` で新しいオブジェクト/配列を返す

```typescript
// OK
function update(item: Item, changes: Partial<Item>): Item {
  return { ...item, ...changes }
}

// NG
function update(item: Item, changes: Partial<Item>): Item {
  Object.assign(item, changes)
  return item
}
```

## コメント

- コードが自明な場合はコメント不要
- 「なぜ」を書く。「何を」はコード自体が説明する
- 変更したコードにのみコメントを追加。既存コードへの追加は不要
- JSDocは公開APIやサービスのインターフェースにのみ使用

## エラーハンドリング

- 予期されるエラー: カスタムエラークラスで分類
- 予期しないエラー: 上位に伝播させ、グローバルハンドラで処理
- エラーを無視しない（空のcatchブロック禁止）

## ファイルサイズ

| 指標 | 推奨 | 上限 |
|:---|:---|:---|
| ファイル行数 | 200-400行 | 800行 |
| 関数行数 | 10-20行 | 50行 |
| 関数の引数 | 1-3個 | オブジェクト引数に切り替え |
| コンポーネントのprops | 3-5個 | 分割を検討 |
