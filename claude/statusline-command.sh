#!/usr/bin/env bash

# Statusline command that mirrors the user's PS1 format.
# Format: user@host:dir (git-branch-with-state)
# Colors: bold green for user@host, bold blue for dir, git colors via SHOWCOLORHINTS.

# Read JSON input from Claude Code.
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // ""')
if [ -z "$cwd" ]; then cwd=$(pwd); fi

# Get username and hostname.
user=$(whoami)
host=$(hostname -s)

# Get current directory basename, like \W, but show ~ for $HOME.
if [[ "$cwd" == "$HOME" ]]; then
  dir="~"
else
  dir=$(basename "$cwd")
fi

# Color codes (matching the PS1 format)
GREEN="\033[01;32m"
BLUE="\033[01;34m"
RESET="\033[00m"

# Try to get git branch info via __git_ps1.
# __git_ps1 is a shell function, not a binary, so use declare -F to detect it.
git_info=""
if ! declare -F __git_ps1 &>/dev/null; then
  # Source git-prompt from well-known locations.
  [[ -r ~/git-prompt.sh ]] && source ~/git-prompt.sh
  [[ -r "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh" ]] && source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
  [[ -r "/usr/share/git-core/git-prompt.sh" ]] && source /usr/share/git-core/git-prompt.sh
  if command -v git &>/dev/null; then
    git_exec_path="$(git --exec-path)"
    [[ -r "${git_exec_path}/git-sh-prompt" ]] && source "${git_exec_path}/git-sh-prompt"
  fi
fi

if declare -F __git_ps1 &>/dev/null && git -C "$cwd" rev-parse --git-dir &>/dev/null 2>&1; then
  # Set git-prompt options to match user's settings.
  export GIT_PS1_SHOWDIRTYSTATE="yes"
  export GIT_PS1_SHOWUPSTREAM="auto"
  export GIT_PS1_SHOWSTASHSTATE="yes"
  export GIT_PS1_SHOWUNTRACKEDFILES="yes"
  export GIT_PS1_SHOWCONFLICTSTATE="yes"
  export GIT_PS1_SHOWCOLORHINTS="yes"

  # Run __git_ps1 in the correct directory context.
  git_info=$(cd "$cwd" && __git_ps1 " (%s)")
  # Strip PS1 \[...\] non-printing markers that __git_ps1 emits with SHOWCOLORHINTS.
  # These tell readline about zero-width chars but appear as literal garbage outside PS1.
  git_info=$(printf '%s' "$git_info" | sed $'s/\001//g; s/\002//g')
fi

# Kubernetes context/namespace (if kubectl is available).
k8s_info=""
if command -v kubectl &>/dev/null; then
  k8s_ctx=$(kubectl config current-context 2>/dev/null)
  if [ -n "$k8s_ctx" ]; then
    k8s_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    k8s_ns="${k8s_ns:-default}"
    k8s_info=" [k8s: ${k8s_ctx}/${k8s_ns}]"
  fi
fi

# AWS profile.
aws_info=""
if [ -n "${AWS_PROFILE:-}" ]; then
  aws_info=" [aws: ${AWS_PROFILE}]"
fi

# Output the status line (without the trailing $).
printf '%b%s@%s%b:%b%s%b%s%s%s\n' "$GREEN" "$user" "$host" "$RESET" "$BLUE" "$dir" "$RESET" "$git_info" "$k8s_info" "$aws_info"
