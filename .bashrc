# If not running interactively, don't do anything
[[ $- == *i* ]] || return

[ -n "$PS1" ] && source ~/.bash_profile;
