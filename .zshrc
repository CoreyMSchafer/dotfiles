autoload -Uz colors && colors
setopt PROMPT_SUBST

# Don't ask if user is sure when running rm with wildcards (like bash)
setopt rmstarsilent

# If wildcard pattern has no matches, return an empty string (like bash)
setopt no_nomatch

# Specify the history file and its sizes
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# These options improve history behavior across sessions
setopt SHARE_HISTORY          # Share command history across all open sessions
setopt APPEND_HISTORY         # Append history rather than overwriting it
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from each command line being added to the history list
setopt HIST_IGNORE_SPACE      # Ignore commands that start with a space (for secret or experimental commands)
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming history

# Load dotfiles:
for file in ~/.{zprompt,aliases,private}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# GitHub Copilot CLI shell integration
eval "$(gh copilot alias -- zsh)"

# YouTube script initialization
# ~/.zshrc
# Usage:
#   yt_init              # init current dir
#   yt_init project_name # create ./project_name, set it up, but stay where you are
yt_init() {
  local template="$HOME/dotfiles/prompts/copilot-instructions.md"
  local gitignore_stack="${GITIGNORE_STACK:-python,macos,visualstudiocode,dotenv}"
  local gitignore_url="https://www.toptal.com/developers/gitignore/api/${gitignore_stack}"
  local orig="$PWD"
  local target="."
  local dir

  # minimal sanity: require template file so we don't error later
  [[ -f "$template" ]] || { echo "Template not found: $template"; return 1; }

  if [[ $# -eq 1 ]]; then
    target="$1"
    uv init "$target" || return     # keep uv’s error behavior
  elif [[ $# -eq 0 ]]; then
    uv init || return
  else
    echo "Usage: yt_init [project_name]"
    return 1
  fi

  dir="$orig"; [[ "$target" == "." ]] || dir="$orig/$target"

  # .gitignore (overwrite with your preferred stack)
  if command -v curl >/dev/null; then
    curl -fsSL "$gitignore_url" -o "$dir/.gitignore" \
      || echo "⚠️  Could not fetch .gitignore; keeping uv's default."
  else
    echo "⚠️  curl not found; keeping uv's default .gitignore."
  fi

  # Copilot instructions + empty sandbox files
  mkdir -p "$dir/.github"
  cp -f "$template" "$dir/.github/copilot-instructions.md"
  : > "$dir/s.txt"
  : > "$dir/sandbox.txt"
  : > "$dir/sandbox.py"

  # Create virtual environment (run from project root)
  ( cd "$dir" && uv venv ) || return

  # Initial commit (assumes brand-new repo with no commits)
  if command -v git >/dev/null; then
    git -C "$dir" add -A
    if git -C "$dir" commit -m "Initial Commit"; then
      echo "✅ Created initial Git commit."
    else
      echo "ℹ️  Git commit skipped/failed (possibly re-ran yt_init or git not configured)."
    fi
  else
    echo "⚠️  git not found; skipping initial commit."
  fi

  echo "✅ Project ready at $dir"
}


# Default WORDCHARS: *?_-.[]~=/&;!#$%^(){}<>
# Modified to exclude forward slash for better path component deletion
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# Created by pipx
export PATH="$PATH:/Users/coreyschafer/.local/bin"
