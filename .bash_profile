# Add to the $PATH. Lower ones have higher priority.
export GEM_HOME="$HOME/.gem:$PATH";
export PATH="$GEM_HOME/bin:$PATH";

export PATH="/usr/bin:$PATH";
export PATH="/usr/sbin:$PATH";
export PATH="/bin:$PATH";
export PATH="/sbin:$PATH";
export PATH="/usr/local/bin:$PATH";
export PATH="/usr/local/sbin:$PATH";

export PATH="/usr/local/git/bin:$PATH";
export PATH="$HOME/bin:$PATH";
export PATH="$HOME/anaconda/bin:$PATH";

# Core Utils
# export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH";
# export MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"

# Load the shell dotfiles, and then some:
# * ~/.private can be used for other settings you don’t want to commit.
for file in ~/.{bash_prompt,aliases,private}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

#Git auto-complete
if [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi

# Auto activate conda environments
function conda_auto_env() {
  if [ -e "environment.yaml" ]; then
    ENV_NAME=$(head -n 1 environment.yaml | cut -f2 -d ' ')
    # Check if you are already in the environment
    if [[ $CONDA_PREFIX != *$ENV_NAME* ]]; then
      # Try to activate environment
      source activate $ENV_NAME &>/dev/null
    fi
  fi
}

export PROMPT_COMMAND="conda_auto_env"
