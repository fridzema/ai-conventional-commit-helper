function commit() {
  git add -A

  # If message provided, commit directly
  if (( $# > 0 )); then
    git commit -m "$*"
    return
  fi

  # Exit early when nothing is staged
  if git diff --cached --quiet; then
    echo "No staged changes to commit"
    return 1
  fi

  # Spinner
  _commit_spinner() {
    local frames="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    while true; do
      for (( i=0; i<${#frames}; i++ )); do
        printf "\r\033[33m${frames:$i:1}\033[0m Generating commit message..."
        sleep 0.08
      done
    done
  }
  local spinner_pid=""

  _commit_cleanup() {
    if [ -n "$spinner_pid" ]; then
      { kill "$spinner_pid"; wait "$spinner_pid"; } 2>/dev/null
      printf "\r\033[K"
    fi
    trap - INT
    return 1
  }
  trap _commit_cleanup INT

  # Build context: stat summary + truncated diff
  local diff_input
  diff_input="$(git diff --cached --stat --no-color && echo '---' && git diff --cached --no-color --unified=2 | head -c 40000)"

  # Generate commit message using haiku for speed
  if [ -t 1 ]; then
    _commit_spinner &!
    spinner_pid=$!
  fi

  local msg
  msg="$(claude -p --model haiku --effort low --no-session-persistence \
    "Write a conventional commit message for this diff.
Format: <type>(<optional scope>): <description>
Types: feat fix refactor docs style test chore perf ci build
Rules:
- Single line, max 72 chars
- Lowercase, imperative mood
- No period at end
- Output ONLY the message, nothing else" <<< "$diff_input")"

  # Stop spinner
  trap - INT
  if [ -n "$spinner_pid" ]; then
    { kill "$spinner_pid"; wait "$spinner_pid"; } 2>/dev/null
    printf "\r\033[K"
  fi

  msg="${msg//$'\n'/}"

  if [ -z "$msg" ]; then
    echo "Failed to generate commit message"
    return 1
  fi

  # Show message and commit
  echo -e "\033[32m✓\033[0m $msg"
  git commit -m "$msg"
}
