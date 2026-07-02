#!/usr/bin/env bash
PROJECTS_DIR="$HOME/projects"
function sanitize() { echo "$1" | tr ' ./' '___'; }
function create_session() {
  local session_name="$1"
  local project_path="$2"
  tmux new-session -d -s "$session_name" -c "$project_path"
  tmux rename-window -t "$session_name:1" "editor"
  tmux send-keys -t "$session_name:editor" "nvim" Enter
  tmux new-window -t "$session_name" -n "opencode" -c "$project_path"
  tmux send-keys -t "$session_name:opencode" "opencode" Enter
  tmux new-window -t "$session_name" -n "lazygit" -c "$project_path"
  tmux send-keys -t "$session_name:lazygit" "lazygit" Enter
  tmux select-window -t "$session_name:editor"
}
active_sessions=$(tmux list-sessions -F "#S (active)" 2>/dev/null)
all_projects=$(find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d ! -name "archive" -printf "%f\n")
combined_list=$(echo -e "${active_sessions}\n${all_projects}")
selected_raw=$(echo "$combined_list" | fzf --prompt "project > ")
[ -z "$selected_raw" ] && exit 0
selected=$(echo "$selected_raw" | sed 's/ (active)//' | sed 's/ ●//' | xargs)
session_name=$(sanitize "$selected")
project_path="$PROJECTS_DIR/$selected"
if ! tmux has-session -t "$session_name" 2>/dev/null; then
  [ ! -d "$project_path" ] && project_path="$HOME"
  create_session "$session_name" "$project_path"
fi
if [ -n "$TMUX" ]; then
  tmux switch-client -t "$session_name"
else
  tmux attach-session -t "$session_name"
fi
