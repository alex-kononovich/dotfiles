function tmux-zipline-app -d "Start Tmux session for zipline-app"
  set -l workdir ~/Projects/RZ/zipline-app
  set -l session_name "zipline-app"

  # layout
  tmux new-session -d -n "code" -c $workdir -s $session_name
  tmux new-window -d -n "tests" -c $workdir -t $session_name
  tmux new-window -d -n "server" -c $workdir -t $session_name
  tmux split-window -d -h -t "$session_name:server" -c $workdir

  # programs
  tmux send-keys -t "$session_name:server.1" "rails server" Enter
  tmux send-keys -t "$session_name:server.2" "foreman start -f Procfile.dev" Enter
  tmux send-keys -t "$session_name:code" "nvim" Enter

  # connect
  tmux attach-session -d -t $session_name
end
