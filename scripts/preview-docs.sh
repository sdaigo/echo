#!/usr/bin/env bash
set -euo pipefail

# プロジェクトルートを基準にする
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SEARCH_DIRS=("docs" ".steering")
EXCLUDE_DIRS=(".claude" "node_modules" ".git")
GLOW_OPTS=("--pager" "--width" "100")

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [file]

Options:
  -a, --all       全マークダウンファイルを対象に含める(.claude/ 等は除外)
  -d, --dir DIR   検索対象ディレクトリを追加(複数指定可)
  -h, --help      このヘルプを表示
  -w, --width N   表示幅を指定(デフォルト: 100)

Examples:
  $(basename "$0")                    # docs/ と .steering/ から選択
  $(basename "$0") docs/glossary.md   # 直接ファイルを指定
  $(basename "$0") -a                 # プロジェクト全体の .md を対象
  $(basename "$0") -d proposals       # proposals/ を追加で検索
EOF
  exit 0
}

check_deps() {
  local missing=()
  for cmd in glow fzf; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Error: missing dependencies: ${missing[*]}" >&2
    echo "Install with: brew install ${missing[*]}" >&2
    exit 1
  fi
}

build_exclude_args() {
  local args=()
  for dir in "${EXCLUDE_DIRS[@]}"; do
    args+=(-path "*/${dir}" -prune -o)
  done
  echo "${args[@]}"
}

find_md_files() {
  local dirs=("$@")
  for dir in "${dirs[@]}"; do
    local abs_dir="${PROJECT_ROOT}/${dir}"
    if [[ -d "$abs_dir" ]]; then
      find "$abs_dir" \
        $(build_exclude_args) \
        -name '*.md' -type f -print 2>/dev/null
    fi
  done | sort
}

preview_file() {
  local file="$1"
  glow "${GLOW_OPTS[@]}" "$file"
}

select_and_preview() {
  local dirs=("$@")
  local files
  files=$(find_md_files "${dirs[@]}")

  if [[ -z "$files" ]]; then
    echo "No markdown files found in: ${dirs[*]}" >&2
    exit 1
  fi

  local relative_files
  relative_files=$(echo "$files" | sed "s|^${PROJECT_ROOT}/||")

  local selected
  selected=$(echo "$relative_files" | fzf \
    --preview "glow --width 80 ${PROJECT_ROOT}/{}" \
    --preview-window "right:60%:wrap" \
    --header "Select a markdown file to preview (ESC to quit)" \
    --height "80%" \
    --border \
    --ansi)

  if [[ -n "$selected" ]]; then
    preview_file "${PROJECT_ROOT}/${selected}"
  fi
}

main() {
  check_deps

  local extra_dirs=()
  local all_mode=false
  local target_file=""
  local width=100

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage ;;
      -a|--all) all_mode=true; shift ;;
      -d|--dir)
        extra_dirs+=("$2")
        shift 2
        ;;
      -w|--width)
        width="$2"
        GLOW_OPTS=("--pager" "--width" "$width")
        shift 2
        ;;
      -*)
        echo "Unknown option: $1" >&2
        usage
        ;;
      *)
        target_file="$1"
        shift
        ;;
    esac
  done

  if [[ -n "$target_file" ]]; then
    if [[ ! -f "$target_file" && -f "${PROJECT_ROOT}/${target_file}" ]]; then
      target_file="${PROJECT_ROOT}/${target_file}"
    fi
    if [[ ! -f "$target_file" ]]; then
      echo "Error: file not found: $target_file" >&2
      exit 1
    fi
    preview_file "$target_file"
    return
  fi

  local search_dirs=()
  if $all_mode; then
    search_dirs=(".")
  else
    search_dirs=("${SEARCH_DIRS[@]}" "${extra_dirs[@]}")
  fi

  select_and_preview "${search_dirs[@]}"
}

main "$@"
