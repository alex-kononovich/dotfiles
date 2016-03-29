if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  /Applications/Postgres.app/Contents/Versions/latest/bin
  node_modules/.bin
  .bin
  $path
)

export LESS='-F -g -i -M -R -S -X -z-4'

export FZF_DEFAULT_OPTS='
  --color bw
'
export FZF_DEFAULT_COMMAND='ag -g ""'
