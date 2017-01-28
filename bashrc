export PS1="\w \\$ "
export BROWSER="open"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_US.UTF-8"
export LESS="-F -g -i -M -R -S -X -z-4"
export PATH=".bin:node_modules/.bin:/Users/alex/.local/bin:$PATH"
export HISTCONTROL=ignoreboth:erasedups

# fix Ctrl-s
stty -ixon

# ls
alias ls="ls -G --color=auto"
alias l="ls -lAh"

# git
alias gr="git recent"
alias gf="git flow"
alias gs="git status"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit --verbose"
alias gca="git commit --verbose --all"
alias gc!="git commit --verbose --amend"
alias gco="git checkout"

# tmux
alias ts="tmux new-session -s"
alias tl="tmux list-sessions"
alias ta="tmux attach-session -t"

# autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh