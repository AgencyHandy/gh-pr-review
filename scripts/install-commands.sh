#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_REPO_BASE="https://raw.githubusercontent.com/AgencyHandy/ahr"
AHR_REF="${AHR_REF:-main}"

usage() {
  cat <<'USAGE'
Install AHR slash command templates.

Usage:
  scripts/install-commands.sh [--global|--project]

Options:
  --global   Install to user-level paths (default)
  --project  Install to current working directory project paths
USAGE
}

copy_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  printf 'Installed %s\n' "$dst"
}

download_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  curl -fsSL "$src" -o "$dst"
  printf 'Installed %s\n' "$dst"
}

install_template() {
  local relative_path="$1"
  local destination="$2"
  local local_source="$REPO_ROOT/$relative_path"

  if [[ -f "$local_source" ]]; then
    copy_file "$local_source" "$destination"
  else
    download_file "$RAW_REPO_BASE/$AHR_REF/$relative_path" "$destination"
  fi
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_codex() {
  local target_home="${CODEX_HOME:-$HOME/.codex}"
  install_template ".codex/prompts/ahr.md" "$target_home/prompts/ahr.md"
}

install_claude() {
  local target_home="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  install_template ".claude/commands/ahr.md" "$target_home/commands/ahr.md"
}

install_opencode() {
  local target_home="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
  install_template ".opencode/commands/ahr.md" "$target_home/commands/ahr.md"
}

MODE="global"
if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

if [[ $# -eq 1 ]]; then
  case "$1" in
    --global)
      MODE="global"
      ;;
    --project)
      MODE="project"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
fi

if [[ "$MODE" == "global" ]]; then
  installed_any=false

  if has_cmd codex || [[ -n "${CODEX_HOME:-}" ]] || [[ -d "$HOME/.codex" ]]; then
    install_codex
    installed_any=true
  else
    printf 'Skipped Codex (not detected)\n'
  fi

  if has_cmd claude || has_cmd claude-code || [[ -n "${CLAUDE_CONFIG_DIR:-}" ]] || [[ -d "$HOME/.claude" ]]; then
    install_claude
    installed_any=true
  else
    printf 'Skipped Claude Code (not detected)\n'
  fi

  if has_cmd opencode || [[ -n "${OPENCODE_CONFIG_DIR:-}" ]] || [[ -d "$HOME/.config/opencode" ]]; then
    install_opencode
    installed_any=true
  else
    printf 'Skipped OpenCode (not detected)\n'
  fi

  if [[ "$installed_any" == false ]]; then
    printf 'No supported agents detected. Install one CLI or rerun with --project.\n'
    exit 1
  fi
else
  PROJECT_ROOT="$PWD"
  install_template ".codex/prompts/ahr.md" "$PROJECT_ROOT/.codex/prompts/ahr.md"
  install_template ".claude/commands/ahr.md" "$PROJECT_ROOT/.claude/commands/ahr.md"
  install_template ".opencode/commands/ahr.md" "$PROJECT_ROOT/.opencode/commands/ahr.md"
fi

printf '\nDone. Use:\n'
printf '  Codex: /prompts:ahr PRS="<url1> <url2>" CONTEXT="..." MODE=full\n'
printf '  Claude/OpenCode: /ahr PRS="<url1> <url2>" CONTEXT="..." MODE=full\n'
