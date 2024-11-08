if [[ "x${_XJORDANX_RUNNING_BASH_PROFILE:-}" != "x" ]]; then
  return;
fi
_XJORDANX_RUNNING_BASH_PROFILE=yes
if [[ "x${_XJORDANX_ENTRYPOINT:-}" = "x" ]]; then
  _XJORDANX_ENTRYPOINT="bash_profile"
fi

#export LESS="-RSMsi"
#export LESS="-RM"

export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
export XDG_STATE_HOME=~/.local/state
export LOCAL_BIN_HOME=~/.local/bin
export PATH="${LOCAL_BIN_HOME}:$PATH"

# <https://www.reddit.com/r/commandline/comments/4m0s58/how_and_why_to_log_your_entire_bash_history/d3rqo3a>
#export PROMPT_COMMAND='history -a'
export HISTSIZE=9999999999999
export HISTFILESIZE=999999999
export HISTTIMEFORMAT='%F %T '
#export HISTCONTROL="erasedups:ignoreboth"
export HISTIGNORE="ls:ll:pwd:exit:su:clear:reboot:history:bg:fg"
export HISTFILE=$XDG_DATA_HOME/bash_history
export INPUTRC=$XDG_CONFIG_HOME/readline/inputrc

export TERM=xterm-256color
export EDITOR=vim
export COLUMNS

alias less='less -IRS'
alias diff='diff --color=always -U9'

# "Fix" for <https://github.com/jqlang/jq/issues/2001> until jq 1.7 is released to Debian.
if (env --split-string --ignore-environment TZ=UTC true 2>&1 || true) | grep -q -E "env: illegal option -- s" ;
then
  export JQ='env  -S             -i                  TZ=UTC jq'
else
  export JQ='env --split-string --ignore-environment TZ=UTC jq'
fi
alias jq="$JQ"

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

if [ $(which go) ]; then
  export GOENV=$XDG_CONFIG_HOME/go/env
  export GOPATH=$(go env GOPATH || echo "$XDG_STATE_HOME/go-path-build/go")
  export PATH=$PATH:$(go env GOBIN):$GOPATH/bin:$GOPATH:$HOME/go/bin:$HOME/go:$(go env GOTOOLDIR):$(go env GOROOT)/bin:$(go env GOROOT)
fi

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1  # $ brew analytics off
if [ -d "/opt/homebrew" ]; then
  export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
fi
if [ $(which brew) ]; then
  if [ $(which pyenv) ]; then
    alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
  fi
  eval "$(brew shellenv)"
  export PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH"
  # BEGIN <https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash>
  if type brew &>/dev/null
  then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
    then
      source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    else
      for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
      do
        [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
      done
    fi
  fi
  # END <https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash>
  eval "$(brew shellenv)"
  if [ -d "$(brew --prefix)/etc/bash_completion.d" ]; then
    while IFS= read -r -d '' file; do
      source $file ;
    done < <(find -H -L "$(brew --prefix)" -maxdepth 6 -name "bash_completion.d" -print0 | xargs -0 -J % find -H -L % -type f | xargs -n1 readlink -f | sort -u | tr "\n" "\0")
    while IFS= read -r -d '' file; do
      source $file ;
    done < <(find -H -L "$(brew --prefix)" -maxdepth 6 -name "completions" -print0 | xargs -0 -J % find -H -L % -type f \( -name '*.bash' -or -name '*.sh' \) | xargs -n 1 readlink -f | sort -u | tr "\n" "\0")
  fi
  [[ -r "$(brew --prefix)/completions/bash/brew" ]] && . "$(brew --prefix)/completions/bash/brew"
  [[ -r "$(brew --prefix)/etc/bash_completion" ]] && . "$(brew --prefix)/etc/bash_completion"
  [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi
# curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/git-completion.bash
# curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/git-prompt.sh
source ~/git-completion.bash
source ~/git-prompt.sh
[[ -r "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh" ]] && source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
[[ -r "/usr/share/git-core/git-prompt.sh" ]] && source /usr/share/git-core/git-prompt.sh
[[ -r "$(git --exec-path)/git-sh-prompt" ]] && source $(git --exec-path)/git-sh-prompt
command -v __git_ps1 > /dev/null
if [ 0 -eq 0 ]; then
   export GIT_PS1_SHOWDIRTYSTATE="yes"
   export GIT_PS1_SHOWUPSTREAM="auto"
   export GIT_PS1_SHOWSTASHSTATE="yes"
   export GIT_PS1_SHOWUNTRACKEDFILES="yes"
   export GIT_PS1_SHOWCONFLICTSTATE="yes"
   export GIT_PS1_SHOWCOLORHINTS="yes"
   # Tweak this as per your needs
   export PS1="$(echo "$PS1" | sed -E -e 's#\\w#\\W#g' -e 's#\\\$ #$(__git_ps1 " (%s)")\$ #g')"
fi
alias g=git
eval $(complete -p git | sed -E -e "s/ git$/ g/g")

export WORKON_HOME=$XDG_STATE_HOME/virtualenvs
#source virtualenvwrapper.sh

# export JAVA_HOME=`/usr/libexec/java_home -v 1.7.0_80`
# export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export JAVA_8_HOME="/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
export JAVA_11_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"
export JAVA_17_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'
alias java17='export JAVA_HOME=$JAVA_17_HOME'
#java8
# export JAVA_OPTS="-XX:+UseG1GC -Xmx4g -Xss4m"  # -XX:MaxMetaspaceSize=768m"
export JAVA_OPTS="-XX:+UseG1GC -Xmx6g -Xss8m"  # -XX:MaxMetaspaceSize=768m"

# pyenv/pyenv* is a personal strategy of creating versioned virtualenvs for each pyenv version, so that pip installing
# stuff doesn't impact the "global" pyenv version.
[[ -d "$XDG_STATE_HOME/pyvenv/pyenv" ]] && (find $XDG_STATE_HOME/pyvenv/pyenv -maxdepth 2 -type d -name 'bin' | grep -q "pyenv/pyenv") && export PATH=$PATH:$(ls $XDG_STATE_HOME/pyvenv/pyenv/pyenv*/bin 2>/dev/null | grep bin | sort -g -r | xargs | sed "s/ /:/g")
[[ -d "$XDG_STATE_HOME/pyvenv/pyenv" ]] && (find $XDG_STATE_HOME/pyvenv/pyenv/versions -depth 2 -type d -name 'bin' | grep -q versions) && export PATH=$PATH:$(find $XDG_STATE_HOME/pyvenv/pyenv/versions -depth 2 -type d -name 'bin' | sort --version-sort --reverse | xargs | sed "s/ /:/g")

#export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

find ~/.ssh \( -name 'id_*' -or -name '*rsa*' -or -name '*dsa*' -or -name '*ed25519*' \) -and \( -not -name '*.*' \) -and \( -not -name '*pub*' \) | xargs ssh-add &>/dev/null

if [ $(which pyenv) ]; then
  export PYENV_ROOT="$XDG_STATE_HOME/pyvenv/pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval $(pyenv init --detect-shell bash)
  export PYENV_INIT_SOURCE_CODE="$(cat << EOF
$(pyenv init --detect-shell bash)
$(pyenv init - --no-push-path bash)
$(pyenv virtualenv-init - bash)
EOF
)"
  alias pyenv-init="eval $PYENV_INIT_SOURCE_CODE"
  # eval `pyenv init - bash` will install bash completions
  # eval `pyenv init -` does not necessarily install completions
  #eval "$PYENV_INIT_SOURCE_CODE"
  #pyenv-init
fi

_gradle() {
  if [ -f gradlew ]; then
    ./gradlew "$@"
  else
    echo '===================================================='
    echo 'No gradle wrapper here please run:'
    echo '    gradle wrapper'
    echo 'to generate the required files for the latest gradle'
    echo '===================================================='
    false
  fi
}

alias gradle=_gradle

if [ $(which kubectl) ]; then
  source <(kubectl completion bash)
  alias kube=kubectl
  alias k=kubectl
  alias k8s=kubectl
  for c in kube k k8s; do
    eval $(complete -p kubectl | sed -E -e "s/ kubectl$/ ${c}/g")
  done
  if [ $(which kubectx) ]; then
    alias kx=kubectx
    alias ctx=kubectx
    for c in kx ctx; do
      eval $(complete -p kubectx | sed -E -e "s/ kubectx$/ ${c}/g")
    done
  fi
  if [ $(which kubens) ]; then
    alias kn=kubens
    alias ns=kubens
    for c in kn ns; do
      eval $(complete -p kubens | sed -E -e "s/ kubens$/ ${c}/g")
    done
  fi
fi

if [ $(which k9s) ]; then
  source <(k9s completion bash)
fi

export KREW_ROOT="${XDG_DATA_HOME}/krew"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if [ $(which kubectx) ]; then
  function kubectx-env {
    env=$1
    if ! (kubectx --current | grep -q $env); then
      current_namespace=$(kubens --current)
      kubectx | grep $env | head -n1 | xargs -r kubectx
      kubens $current_namespace || true
      kubectx --current | grep -q $env
    else
      true
    fi
  }
  alias kx-env=kubectx-env
  alias ctx-env=kubectx-env
  function kubectx-dev {
    kubectx-env dev
  }
  alias kx-dev=kubectx-dev
  alias ctx-dev=kubectx-dev
  function kubectx-prod {
    kubectx-env prod || kubectx-env prd
  }
  alias kx-prod=kubectx-prod
  alias ctx-prod=kubectx-prod
  function kubectx-staging {
    kubectx-env staging || kubectx-env stage || kubectx-env stg
  }
  alias kx-staging=kubectx-staging
  alias ctx-staging=kubectx-staging
  function kubectx-sandbox {
    kubectx-env sandbox || kubectx-env sand
  }
  alias kx-sandbox=kubectx-sandbox
  alias ctx-sandbox=kubectx-sandbox
  function kubectx-ci {
    kubectx-env ci
  }
  alias kx-ci=kubectx-ci
  alias ctx-ci=kubectx-ci
fi

# BEGIN bash completion support for Pants
# Generated from ``pants --no-verify-config complete``
function _pants_completions() {
    local current_word
    current_word=${COMP_WORDS[COMP_CWORD]}

    # Check if we're completing a relative (.), absolute (/), or homedir (~) path. If so, fallback to readline (default) completion.
    # This short-circuits the call to the complete goal, which can take a couple hundred milliseconds to complete
    if [[ $current_word =~ "^(\.|/|~\/)" ]]; then
        COMPREPLY=()
    else
        # Call the pants complete goal with all of the arguments that we've received so far.
        COMPREPLY=( $(pants complete -- "${COMP_WORDS[@]}") )
    fi

    return 0
}

complete -o default -F _pants_completions pants
# END bash completion support for Pants

#export PS1="\u@\h \W \$(kprompt) \[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

export MANPATH="${MANPATH:-}:/usr/local/opt/erlang/lib/erlang/man:"

export PATH="$PATH:/usr/local/opt/mysql-client@5.7/bin"
export PATH=/usr/local/opt/curl/bin:$PATH

if [ $(which aws) ]; then
  if [ -f ~/.aws/config ]; then
    export AWS_PROFILE=$(grep --color=never -E "^[[]profile .*dev" ~/.aws/config | head -n1 | sed -E -e "s/^.*profile //g" -e "s/[]]//g")
    function aws-sso-login {
      aws sso login --profile $AWS_PROFILE
    }
  fi
fi

find_quote_spaces() {
  find "$@" | sed -E -e 's#(.*)#"\1"#g' -e "s# #\\ #g"
}

find_quote_spaces_all() {
  find . | sed -E 's/(.*)/"\1"/g' | sed -E "s/ /\\ /g"
}

# Any commands that shouldn't be committed, because they are hyper-specific to a particular non-personal environment and
# cannot be generalized. e.g.
#     export PATH="/opt/homebrew/opt/kubernetes-cli@1.29/bin:$PATH"
# because a particular non-personal project is using that specific old version of kubernetes.
if [ -f ~/.bash_profile_gitignore ]; then
    . ~/.bash_profile_gitignore
fi

# <https://direnv.net/docs/hook.html>
# "Make sure it appears even after rvm, git-prompt and other shell extensions that manipulate the prompt."
(type direnv &>/dev/null) && eval "$(direnv hook bash)"

if [[ "${_XJORDANX_ENTRYPOINT:-}" = "bash_profile" ]]; then
  export -n _XJORDANX_RUNNING_BASHRC _XJORDANX_RUNNING_BASH_PROFILE _XJORDANX_ENTRYPOINT this_entrypoint
  unset _XJORDANX_RUNNING_BASHRC _XJORDANX_RUNNING_BASH_PROFILE _XJORDANX_ENTRYPOINT this_entrypoint
  export -n _XJORDANX_RUNNING_BASHRC _XJORDANX_RUNNING_BASH_PROFILE _XJORDANX_ENTRYPOINT this_entrypoint
fi
