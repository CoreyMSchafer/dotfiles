autoload -Uz colors && colors
setopt PROMPT_SUBST

# Deduplicate PATH so re-sourcing doesn't grow it
typeset -U path PATH

# Don't ask if user is sure when running rm with wildcards (like bash)
setopt rmstarsilent

# If wildcard pattern has no matches, return an empty string (like bash)
setopt no_nomatch

# History file and size
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000

# History behavior
setopt EXTENDED_HISTORY       # Record timestamp + elapsed time per entry
setopt SHARE_HISTORY          # Share command history across all open sessions
setopt APPEND_HISTORY         # Append history rather than overwriting it
setopt HIST_REDUCE_BLANKS     # Trim extra blanks
setopt HIST_IGNORE_SPACE      # Skip commands that start with a space
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming history

# uv-installed tools (ruff, ty, djlint, …) live here; on Linux, bat and fd too.
# Before the dotfiles load so .aliases can see them.
export PATH="$PATH:$HOME/.local/bin"

# Load dotfiles:
for file in ~/.{zprompt,aliases,private}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Default minus "/" so word-deletion stops at path components
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# fzf: use the terminal's 16-color palette
export FZF_DEFAULT_OPTS='--color=16'

# Added by fzf installer
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide: `z <dir>` jumps to frequently used directories
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
