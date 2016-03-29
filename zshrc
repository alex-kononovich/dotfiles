if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

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

# rails
alias rdm="rake db:migrate"
alias rdr="rake db:rollback"
alias rc="rails console"
alias RET="RAILS_ENV=test"
