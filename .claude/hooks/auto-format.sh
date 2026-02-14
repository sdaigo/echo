#!/bin/bash
# PostToolUse hook: Edit/Write後にBiomeで自動フォーマット
#
# 入力: stdin に JSON（tool_input.file_path を含む）
# 出力: フォーマット結果（成功/スキップ）

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Biome対象の拡張子のみ処理
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.jsonc|*.css)
    ;;
  *)
    exit 0
    ;;
esac

# ファイルが存在しない場合はスキップ（削除操作等）
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Biomeでフォーマット（プロジェクトルートから実行）
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null

if command -v bunx &>/dev/null && [ -f "node_modules/.bin/biome" ]; then
  bunx biome check --write "$FILE_PATH" 2>/dev/null
fi

# フォーマットの成否に関わらず成功を返す（ブロックしない）
exit 0
