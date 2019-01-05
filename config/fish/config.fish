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

# $PATH
set -l brew_path '/usr/local/opt'

set -x RUST_PATH "$HOME/.cargo"

set coreutils_path "$brew_path/coreutils"

set fish_user_paths \
  '.bin' \
  'node_modules/.bin' \
  "$HOME/.local/bin" \
  "$RUST_PATH/bin" \
  "$coreutils_path/libexec/gnubin"

# $MANPATH is generated by /usr/libexec/path_helper utility, but only if there
# IS something in $MANPATH already. 
# https://github.com/fish-shell/fish-shell/issues/1092#issuecomment-189576438
# Fish is following the same procedure:
# https://github.com/fish-shell/fish-shell/commit/6b536922af23086197fd9fa5a9e14dbcc84e57c8
# Also $MANPATH is empty from the start.
# This results in following situation: if I'm trying to append coreutils man
# path to $MANPATH, it contains only coreutils man path, which makes it not
# possible to search other man pages. And when I'm creating a tmux session, then
# path_helper kicks in, and I have these paths (/usr/share/etc) plus coreutils
# path twice.
# So I figured I'd rather hardcode paths here.
set -x MANPATH "$coreutils_path/libexec/gnuman" "/usr/share/man" "/usr/local/share/man"

alias e=$EDITOR

# git
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
