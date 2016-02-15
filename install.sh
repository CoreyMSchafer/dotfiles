#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ${homedir}/dotfiles
############################

########## Variables

if [ "$#" -ne 1 ]; then
    echo "Usage: install.sh <home_directory>"
    exit 1
fi

homedir=$1

dir=${homedir}/dotfiles                    # dotfiles directory
olddir=${homedir}/dotfiles_old             # old dotfiles backup directory
files="aliases bash_profile bash_prompt bashrc functions path private"    # list of files/folders to symlink in ${homedir}

##########

curl "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" > ${homedir}/.git-completion.bash

# create dotfiles_old in ${homedir}
echo "Creating ${olddir} for backup of any existing dotfiles in ${homedir}"
mkdir -p ${olddir}
echo "...done"

# change to the dotfiles directory
echo "Changing to the ${dir} directory"
cd ${dir}
echo "...done"

# move any existing dotfiles in ${homedir} to dotfiles_old directory, then create symlinks
for file in ${files}; do
    echo "Moving any existing dotfiles from ${homedir} to ${olddir}"
    mv ${homedir}/.${file} ${homedir}/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s ${dir}/.${file} ${homedir}/.${file}
done