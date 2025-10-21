function tmux-dotfiles -d "Start Tmux session for my dotfiles"
  set -l workdir ~/.dotfiles
  set -l session_name "dotfiles"

  # layout
  tmux new-session -d -n "code" -c $workdir -s $session_name

  # programs
  tmux send-keys -t "$session_name:code" "nvim" Enter

  # connect
  tmux attach-session -d -t $session_name
end
