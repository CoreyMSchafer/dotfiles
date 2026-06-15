#!/usr/bin/env bash
#
# Claude Code PostToolUse hook — auto-format the file Claude just edited.
#
# Wired up in ~/.claude/settings.json (symlinked from dotfiles/claude/settings.json):
#   "PostToolUse" matcher "Edit|Write|MultiEdit" -> this script.
#
# The hook payload arrives as JSON on stdin; the edited file's absolute path is
# at .tool_input.file_path. We format by extension, best-effort, and NEVER block
# Claude (no exit 2). For Python we additionally surface any lint that ruff
# could not auto-fix as `additionalContext`, so the model can decide what to do
# rather than being forced to.
#
# Source of truth (version-controlled): ~/dotfiles/claude/hooks/format.sh

set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

# Nothing to do without a real, still-present file.
[[ -n "$file" && -f "$file" ]] || exit 0

case "$file" in
  *.py)
    command -v ruff >/dev/null 2>&1 || exit 0
    cd "$(dirname "$file")" || exit 0      # so ruff discovers this project's config
    # Fix first, then format (matches AGENTS.md process order and ruff-pre-commit).
    ruff check --fix "$file"  >/dev/null 2>&1 || true
    ruff format "$file"       >/dev/null 2>&1 || true
    # Re-check (no fix): if anything remains, hand it back to Claude as context.
    if ! remaining=$(ruff check "$file" 2>&1); then
      jq -n --arg c "$remaining" \
        '{hookSpecificOutput:{hookEventName:"PostToolUse",
          additionalContext:("ruff (after auto-fix) still flags this file:\n"+$c)}}'
    fi
    ;;
  *.html|*.jinja|*.jinja2|*.j2)
    command -v djlint >/dev/null 2>&1 || exit 0
    ( cd "$(dirname "$file")" && djlint "$file" --reformat >/dev/null 2>&1 ) || true
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.css|*.scss)
    command -v prettier >/dev/null 2>&1 || exit 0
    ( cd "$(dirname "$file")" && prettier --write "$file" >/dev/null 2>&1 ) || true
    ;;
esac

exit 0
