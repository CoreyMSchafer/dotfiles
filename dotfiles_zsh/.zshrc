# If not running interactively, don't do anything
[[ $- == *i* ]] || return

# -n Checks if the length of a string is nonzero.
[ -n "$PS1" ] && source ~/.zprofile;
