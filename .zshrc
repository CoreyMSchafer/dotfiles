# Define the prompt_git function for git repository status
prompt_git() {
    local git_status=''
    local branchName=''

    # Check if the current directory is in a Git repository.
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        # Get the status summary.
        local gitSummary=$(git status --porcelain)

        # Check for uncommitted changes in the index, unstaged changes, untracked files, and stashed files.
        [[ -n $(echo "$gitSummary" | grep '^M') ]] && git_status+='+'
        [[ -n $(echo "$gitSummary" | grep '^ M') ]] && git_status+='!'
        [[ -n $(echo "$gitSummary" | grep '^\?\?') ]] && git_status+='?'
        [[ $(git rev-parse --verify refs/stash &>/dev/null; echo "${?}") == '0' ]] && git_status+='$'

        # Get the short symbolic ref or the short SHA for the latest commit.
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null || echo '(unknown)')"

        [ -n "${git_status}" ] && git_status=" [${git_status}]"

        printf "%b on %b%s%s" "${white}" "${blue}" "${branchName}" "${git_status}"

    else
        return
    fi
}

prompt_pyenv() {
    if [ -n "${VIRTUAL_ENV_PROMPT:-}" ] && [ -n "${_OLD_VIRTUAL_PS1:-}" ]; then
        PS1="${_OLD_VIRTUAL_PS1:-}"
        export PS1
        printf "\n%bVENV: %s\n" "${steel_blue}" "${VIRTUAL_ENV_PROMPT}"
    else
        return
    fi
}

# Initialize color variables using tput. This should work similarly in Zsh.
autoload -Uz colors && colors
tput sgr0; # reset colors
bold=$(tput bold)
reset=$(tput sgr0)
blue=$(tput setaf 153)
steel_blue=$(tput setaf 67)
green=$(tput setaf 71)
orange=$(tput setaf 166)
red=$(tput setaf 167)
white=$(tput setaf 15)
yellow=$(tput setaf 228)

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
    userStyle="${red}"
else
    userStyle="${orange}"
fi

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${bold}${red}"
else
    hostStyle="${yellow}"
fi

setopt PROMPT_SUBST

# Properly using variables and command substitution in Zsh PROMPT
PS1="\$(prompt_pyenv)"
PS1+="%{${bold}%}"$'\n'
PS1+="%{${userStyle}%}%n"
PS1+="%{${white}%} at "
PS1+="%{${hostStyle}%}%m"
PS1+="%{${white}%} in "
PS1+="%{${green}%}%c"
PS1+="\$(prompt_git)"
PS1+=$'\n'
PS1+="%{${white}%}\$ %{${reset}%}"
export PS1

PS2="%{${yellow}%}→ %{${reset}%}"
export PS2
