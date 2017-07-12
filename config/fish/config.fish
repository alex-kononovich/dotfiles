# set vi key bindings
fish_vi_key_bindings

# remove greeting
set fish_greeting

set -x EDITOR 'nvim'
set -x VISUAL 'nvim'
set -x BROWSER 'open'
set -x LESS (echo -n \
  # display colors and such
  --RAW-CONTROL-CHARS \
  # do not ask me to press RETURN if everything fits in one screen
  --quit-if-one-screen \
  # do not mess things up
  --no-init \
  # do not do line wrapping
  --chop-long-lines \
  # show more info
  --LONG-PROMPT \
  # highlight only current match, not ALL matches
  --hilite-search \
  # ignore case when searching
  --ignore-case \
  # keep 4 lines from the previous screen (when using PgDown)
  --window=-4 \
  # show tabs as 4 spaces, not 8
  --tabs=4
)

# $PATH
set coreutils_path '/usr/local/opt/coreutils' 
set fish_user_paths \
  '.bin' \
  'node_modules/.bin' \
  "$HOME/.local/bin" \
  "$coreutils_path/libexec/gnubin"

set -x MANPATH $MANPATH "$coreutils_path/libexec/gnuman"

# ls
alias ls='ls --color=auto'
alias l='ls -lAh'

# git
alias gr='git recent'
alias gf='git flow'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gc!='git commit --verbose --amend'
alias gco='git checkout'

# tmux
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias ta='tmux attach-session -t'

# autojump
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

