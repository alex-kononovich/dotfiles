set -x EDITOR 'nvim'
set -x VISUAL 'nvim'

# $PATH
set coreutils_path '/usr/local/opt/coreutils' 
set fish_user_paths \
  '.bin' \
  'node_modules/.bin' \
  "$HOME/.local/bin" \
  "$coreutils_path/libexec/gnubin"

set -x MANPATH $MANPATH "$coreutils_path/libexec/gnuman"

# autojump
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

