# Claude Code config

Version-controlled pieces of my [Claude Code](https://claude.com/claude-code) setup.

## What lives here vs. what stays local

- **`hooks/`** — shareable hook scripts (safe to publish). Referenced by absolute
  path from `~/.claude/settings.json`, so they do not need symlinking.
- **`settings.example.json`** — a sanitized reference for `~/.claude/settings.json`.
- **`~/.claude/settings.json` itself stays machine-local and is NOT in this repo.**
  It can hold personal/safety toggles (e.g. `skipDangerousModePermissionPrompt`)
  that should not be published to a public dotfiles repo.

## Hooks

### `hooks/format.sh` — PostToolUse auto-formatter

Runs after Claude edits a file (`Edit`/`Write`/`MultiEdit`) and formats it by
extension, best-effort and non-blocking:

- `.py` → `ruff format` + `ruff check --fix`; any lint ruff can't auto-fix is
  handed back to Claude as context (it is not forced to act on it).
- `.html` / `.jinja` / `.j2` → `djlint --reformat`
- `.js` / `.jsx` / `.ts` / `.tsx` / `.css` / `.scss` → `prettier --write`

Each formatter is skipped if its tool isn't installed, so the hook is safe on any
project. It reads the edited file path from the hook payload on stdin
(`.tool_input.file_path`).

## Wiring it up

`install.sh` makes the hook scripts executable and, if you have no
`~/.claude/settings.json` yet, seeds one from `settings.example.json`. If you
already have a settings file, merge the `hooks` block from the example by hand.

Test a hook directly:

```bash
printf '%s' '{"tool_name":"Write","tool_input":{"file_path":"/path/to/file.py"}}' \
  | ~/dotfiles/claude/hooks/format.sh
```

Or watch it fire live with `claude --debug` and edit a file.
