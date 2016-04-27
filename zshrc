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
alias devlog="tail -f log/development.log"
alias testlog="tail -f log/test.log"

# heroku

# When switching between feature branches it's sometimes needed to migrate db to
# known state. Here we using production database as common denominator.
function resetdb () {
  dbname=$(print_db_name)
  dropdb $dbname
  createdb $dbname
  pg_restore --verbose --clean --no-acl --no-owner -d $dbname tmp/production.dump
  rake db:migrate
}

# download db from backups
function downloaddb () {
  curl -o tmp/production.dump `heroku pg:backups public-url -r production`
}

# private, used to read database name from config
function print_db_name () {
  ruby -e 'require "YAML"; puts YAML.load(IO.read("config/database.yml"))["development"]["database"]'
}
