# If not running interactively, exit script
[[ $- != *i* ]] && return

# Load dotfiles:
for file in ~/.{bash_prompt,aliases,private}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# GitHub Copilot CLI shell integration
eval "$(gh copilot alias -- bash)"
