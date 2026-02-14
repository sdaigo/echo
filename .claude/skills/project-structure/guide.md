# プロジェクト構造定義書作成ガイド

このガイドは、アーキテクチャ設計書に基づいて、保守性が高く一貫性のあるプロジェクト構造を定義するための実践的な指針を提供します。

## プロジェクト構造定義書の目的

プロジェクト構造定義書は、アーキテクチャ設計で決定された技術スタックとレイヤー構成を、具体的なディレクトリ・ファイル配置に落とし込むドキュメントです。

### 主な内容

- ルートディレクトリ構成
- ソースコードのディレクトリ構造（レイヤーごと）
- 命名規則（ファイル名、ディレクトリ名、エクスポート）
- モジュール境界と依存関係ルール
- 設定ファイルの配置と役割
- テストファイルの配置戦略

## 作成の基本フロー

### ステップ1: アーキテクチャ設計書の確認

プロジェクト構造はアーキテクチャ設計の具体化です。以下を確認します:

- レイヤードアーキテクチャの構成
- 技術スタック（フレームワーク固有のディレクトリ規約）
- データ永続化方式
- テスト戦略

### ステップ2: ルートディレクトリ構成の定義

プロジェクトルート直下のファイル・ディレクトリを定義します。

**良い例**:
```text
/
├── src/                  # アプリケーションソースコード
├── public/               # 静的アセット
├── tests/                # テストファイル（e2e）
├── docs/                 # プロジェクトドキュメント
├── .github/              # GitHub Actions等
├── package.json
├── tsconfig.json
└── biome.json
```

**注意**: フレームワーク固有の規約を尊重すること（例: Next.js App Routerの `app/` ディレクトリ）

### ステップ3: ソースコードの構造化

アーキテクチャのレイヤーをディレクトリ構成に反映します。

#### 原則1: レイヤーの物理的分離

各レイヤーを明確なディレクトリで分離します。

**悪い例**:
```text
src/
├── components/
│   ├── TaskList.tsx        # UIとビジネスロジックが混在
│   └── taskUtils.ts        # どのレイヤーか不明
```

**良い例**:
```text
src/
├── app/                    # UIレイヤー（ルーティング・ページ）
├── components/             # UIレイヤー（再利用可能コンポーネント）
├── services/               # サービスレイヤー（ビジネスロジック）
├── repositories/           # データレイヤー（DB操作）
├── lib/                    # 共通ユーティリティ
└── types/                  # 型定義
```

#### 原則2: コロケーション（関連ファイルの近接配置）

密結合なファイルは近くに配置します。

**悪い例**:
```text
src/
├── components/
│   └── EventCard.tsx
├── styles/
│   └── EventCard.module.css    # 離れた場所にスタイル
├── tests/
│   └── EventCard.test.tsx      # 離れた場所にテスト
```

**良い例**:
```text
src/components/
├── event-card/
│   ├── event-card.tsx
│   ├── event-card.test.tsx     # テストを近接配置
│   └── index.ts                # 公開APIの制御
```

#### 原則3: 機能単位のグルーピング（features/ディレクトリ）

ドメイン固有のロジック・UI・型をまとめて、機能単位でモジュール化します。

##### features/ を使う基準

| 条件 | features/ に入れる | 共通ディレクトリに入れる |
|:---|:---|:---|
| 特定の業務機能に閉じている | Yes | - |
| 複数の機能から参照される | - | Yes (`components/`, `lib/` 等) |
| ページ固有のUIパーツ | Yes | - |
| 汎用的なUIパーツ (Button等) | - | Yes (`components/ui/`) |

##### features/ 内部の構成規則

各featureは、レイヤー構成のミニチュアとして構成します:

```text
src/features/
├── extraction/              # AI抽出機能
│   ├── components/          # この機能に閉じたUIコンポーネント
│   │   ├── image-preview.tsx
│   │   └── extraction-result.tsx
│   ├── services/            # この機能のビジネスロジック
│   │   └── extraction-service.ts
│   ├── types/               # この機能の型定義
│   │   └── extraction-types.ts
│   ├── hooks/               # この機能のカスタムフック（任意）
│   │   └── use-extraction.ts
│   └── index.ts             # 公開API（外部に公開するもののみexport）
├── events/                  # 行事管理機能
│   ├── components/
│   ├── services/
│   ├── types/
│   └── index.ts
```

##### features/ の依存関係ルール

```text
feature間の依存:
  extraction/ → events/       (NG: feature間の直接依存は禁止)
  extraction/ → lib/          (OK: 共通ユーティリティは参照可)
  extraction/ → components/   (OK: 共通UIコンポーネントは参照可)
  extraction/ → types/        (OK: 共通型定義は参照可)

feature間で共有が必要になった場合:
  → 共有部分を lib/ または components/ に昇格させる
```

##### features/ と app/ (ルーティング) の関係

`app/` はルーティングのみを担当し、`features/` から公開されたコンポーネントとサービスを利用します:

```text
app/extraction/page.tsx
  └── import { ExtractionResult } from '@/features/extraction'  (OK)
  └── import { extractionService } from '@/features/extraction'  (NG: Server Actionで呼ぶ)

app/extraction/actions.ts (Server Actions)
  └── import { extractionService } from '@/features/extraction'  (OK)
```

##### 共通ディレクトリとの使い分け早見表

| ディレクトリ | 配置するもの | 例 |
|:---|:---|:---|
| `features/[name]/components/` | 機能固有のUI | 抽出結果カード、行事編集フォーム |
| `features/[name]/services/` | 機能固有のロジック | AI抽出処理、iCal生成 |
| `features/[name]/types/` | 機能固有の型 | ExtractionResult型 |
| `components/ui/` | 汎用UIパーツ | Button, Dialog, Card |
| `components/layout/` | レイアウト部品 | Header, Footer, Sidebar |
| `lib/` | 機能横断ユーティリティ | 日付フォーマット, バリデーション |
| `types/` | 機能横断の型定義 | APIレスポンス共通型, DB型 |

### ステップ4: 命名規則の定義

一貫性のある命名規則を文書化します。

#### ファイル名

| 種別 | 規則 | 例 |
|:---|:---|:---|
| コンポーネント | kebab-case | `event-card.tsx` |
| サービス | kebab-case | `extraction-service.ts` |
| 型定義 | kebab-case | `event-types.ts` |
| テスト | `*.test.ts(x)` | `event-card.test.tsx` |
| 定数 | kebab-case | `error-messages.ts` |
| 設定ファイル | ツール規約に従う | `biome.json`, `tsconfig.json` |

#### ディレクトリ名

| 規則 | 例 |
|:---|:---|
| kebab-case | `event-card/`, `auth-provider/` |
| 機能単位の場合は単数形 | `extraction/` (not `extractions/`) |
| レイヤー単位の場合は複数形 | `components/`, `services/` |

#### エクスポート

| 種別 | 規則 | 例 |
|:---|:---|:---|
| コンポーネント | PascalCase (named export) | `export function EventCard()` |
| 関数 | camelCase (named export) | `export function extractEvents()` |
| 型 | PascalCase (named export) | `export type EventData = {...}` |
| 定数 | UPPER_SNAKE_CASE | `export const MAX_FILE_SIZE = ...` |
| デフォルトエクスポート | 原則禁止 | barrel file (index.ts) のみ例外 |

### ステップ5: モジュール境界と依存関係ルール

レイヤー間・モジュール間の依存方向を明文化します。

```text
依存関係ルール:
  app/ (UIレイヤー)
    ├── 許可: components/, services/, lib/, types/
    └── 禁止: repositories/ への直接アクセス

  components/ (UIレイヤー)
    ├── 許可: lib/, types/
    └── 禁止: services/, repositories/ への直接アクセス

  services/ (サービスレイヤー)
    ├── 許可: repositories/, lib/, types/
    └── 禁止: app/, components/ への依存

  repositories/ (データレイヤー)
    ├── 許可: lib/, types/
    └── 禁止: app/, components/, services/ への依存
```

### ステップ6: 設定ファイルの配置

プロジェクトルートに配置される設定ファイルの一覧と役割を文書化します。

| ファイル | 役割 | 備考 |
|:---|:---|:---|
| `package.json` | 依存関係、スクリプト定義 | |
| `tsconfig.json` | TypeScript設定 | パスエイリアス含む |
| `biome.json` | Linter + Formatter設定 | |
| `next.config.ts` | Next.js設定 | フレームワーク固有 |
| `.env.local` | 環境変数（ローカル） | `.gitignore`に含める |
| `.env.example` | 環境変数テンプレート | Gitで管理 |

### ステップ7: テストファイル配置戦略

テストの種類ごとに配置ルールを定義します。

| テスト種別 | 配置場所 | 理由 |
|:---|:---|:---|
| ユニットテスト | ソースファイルと同階層 | コロケーションによる保守性 |
| 統合テスト | `tests/integration/` | 複数モジュールの結合テスト |
| E2Eテスト | `tests/e2e/` | アプリケーション全体のテスト |
| テストユーティリティ | `tests/helpers/` | テスト間で共有するモック等 |

## レビュー観点

プロジェクト構造定義書を以下の観点でレビューします:

1. アーキテクチャ設計書のレイヤー構成と整合しているか
2. フレームワーク固有の規約を尊重しているか
3. 命名規則が一貫しているか
4. 依存関係ルールが明確で、レイヤー違反を防げるか
5. テストファイルの配置が明確か
6. 新規メンバーが迷わずファイルを配置できるか

## チェックリスト

- [ ] ルートディレクトリ構成が定義されている
- [ ] ソースコードがレイヤーごとに分離されている
- [ ] 命名規則（ファイル、ディレクトリ、エクスポート）が統一されている
- [ ] モジュール境界と依存関係ルールが明文化されている
- [ ] 設定ファイルの一覧と役割が記載されている
- [ ] テストファイルの配置ルールが定義されている
- [ ] フレームワーク固有の規約との整合性がある
- [ ] 各ディレクトリの責務が明確に説明されている
