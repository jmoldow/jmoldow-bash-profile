#!/usr/bin/env bash

# Statusline command that mirrors the user's PS1 format
# Format: username@hostname:directory (git-branch)
# Colors: green for user@host, blue for directory

# Get username and hostname
user=$(whoami)
host=$(hostname -s)

# Get current directory (basename only, like \W)
dir=$(basename "$PWD")

# Replace home directory with ~
if [[ "$PWD" == "$HOME" ]]; then
  dir="~"
elif [[ "$PWD" == "$HOME"/* ]]; then
  dir="~/${PWD#$HOME/}"
  dir=$(basename "$dir")
fi

# Color codes (matching the PS1 format)
GREEN="\033[01;32m"
BLUE="\033[01;34m"
RESET="\033[00m"

# Try to get git branch info if __git_ps1 is available
git_info=""
if command -v __git_ps1 &>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
  # Source git-prompt if needed
  if ! declare -F __git_ps1 &>/dev/null; then
    [[ -r ~/git-prompt.sh ]] && source ~/git-prompt.sh
    [[ -r "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh" ]] && source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
    [[ -r "/usr/share/git-core/git-prompt.sh" ]] && source /usr/share/git-core/git-prompt.sh
    if command -v git &>/dev/null && [[ -r "$(git --exec-path)/git-sh-prompt" ]]; then
      source "$(git --exec-path)/git-sh-prompt"
    fi
  fi

  # Set git-prompt options to match user's settings
  export GIT_PS1_SHOWDIRTYSTATE="yes"
  export GIT_PS1_SHOWUPSTREAM="auto"
  export GIT_PS1_SHOWSTASHSTATE="yes"
  export GIT_PS1_SHOWUNTRACKEDFILES="yes"
  export GIT_PS1_SHOWCONFLICTSTATE="yes"

  if declare -F __git_ps1 &>/dev/null; then
    git_info=$(__git_ps1 " (%s)")
  fi
fi

# Output the status line (without the trailing $)
echo -e "${GREEN}${user}@${host}${RESET}:${BLUE}${dir}${RESET}${git_info}"
