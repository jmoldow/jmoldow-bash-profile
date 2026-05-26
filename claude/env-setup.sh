#!/usr/bin/env bash
export PAGER=cat
export GIT_PAGER=cat

ACTIVATE_PATHS="$(find . -mindepth 2 -maxdepth 3 -path '*/bin/activate' -type f)"

if [[ -f bin/activate ]]; then
  source bin/activate
elif [[ $(wc -l <<<"$ACTIVATE_PATHS") -eq 1 ]]; then
  source "$ACTIVATE_PATHS"
else
  ACTIVATE_PATHS="$(grep "env/bin/activate" <<<"$ACTIVATE_PATHS")"
  if [[ $(wc -l <<<"$ACTIVATE_PATHS") -eq 1 ]]; then
    source "$ACTIVATE_PATHS"
  fi
fi
