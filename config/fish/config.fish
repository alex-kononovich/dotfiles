# remove greeting
set fish_greeting

set -x EDITOR 'nvim'
set -x VISUAL $EDITOR
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

set -x MANWIDTH 100

set -x RUST_PATH "$HOME/.cargo"

set fish_user_paths \
  '.bin' \
  'node_modules/.bin' \
  "$HOME/.local/bin" \
  "$RUST_PATH/bin"

alias e=$EDITOR

# git
abbr --add gp 'git push'
abbr --add gr 'git recent'
abbr --add gf 'git flow'
abbr --add gs 'git status'
abbr --add gd 'git diff -w'
abbr --add gdc 'git diff --cached -w'
abbr --add ga 'git add'
abbr --add gaa 'git add --all'
abbr --add gc 'git commit --verbose'
abbr --add gca 'git commit --verbose --all'
abbr --add gc! 'git commit --verbose --amend'
abbr --add gco 'git checkout'
abbr --add gcm 'git checkout master'
abbr --add hco 'hub checkout'

# tmux
alias ts='tmux new-session -A -s'
alias tl='tmux list-sessions'

# docker
abbr --add dc 'docker-compose'

# autojump
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

# chruby
source /usr/local/share/chruby/chruby.fish
source /usr/local/share/chruby/auto.fish

# direnv
eval (direnv hook fish)

# nodenv
status --is-interactive; and source (nodenv init - | psub)

# aws completions
test -x (which aws_completer); and complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
