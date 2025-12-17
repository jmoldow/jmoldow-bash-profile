if [[ "x${_XJORDANX_RUNNING_BASH_PROFILE:-}" != "x" ]]; then
  return;
fi
_XJORDANX_RUNNING_BASH_PROFILE=yes
if [[ "x${_XJORDANX_ENTRYPOINT:-}" = "x" ]]; then
  _XJORDANX_ENTRYPOINT="bash_profile"
fi

export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
export XDG_STATE_HOME=~/.local/state
export LOCAL_BIN_HOME=~/.local/bin
export PATH="${LOCAL_BIN_HOME}:$PATH"

# append to the history file, don't overwrite it
shopt -s histappend
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

#export LESS="-RSMsi"
#export LESS="-RM"
export LESSHISTSIZE=999999999
export LESSHISTFILE=$XDG_DATA_HOME/lesshst
export LESS='RISM'
alias less='less -RISM'
alias diff='diff --color=auto -U3'

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
  export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"
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
   alias init-tput="tput init"
   alias clear-formatting="tput init"
fi
alias g=git
function git-root-from-toplevel() {
  git -C "$(git root-show)" "$@"
}
alias g-root-from-toplevel=git-root-from-toplevel
function git-root() {
  git "$@" "$(git root-show)"
}
alias g-root=git-root
alias git-root-relative=git-root
alias g-root-relative=git-root
function git-local() {
  git "$@" .
}
alias g-local=git-local
for c in g git-root-from-toplevel g-root-from-toplevel git-root g-root git-root-relative g-root-relative git-local g-local; do
  eval "$(complete -p git | sed -E -e "s/ git$/ ${c}/g")"
done

function git-worktree-switch-branch() {
  branch="$1"
  branch_no_slashes="$(echo "$branch" | tr "/" "-")"
  worktree_root="$(git root-show)/git-worktrees"
  worktree_path="${worktree_root}/${branch_no_slashes}"
  mkdir -p "$(git root-show)/git-worktrees"
  [[ ! -d $worktree_path ]] || git worktree remove "$worktree_path"
  git worktree prune
  git-root-from-toplevel worktree add --checkout "$worktree_path" "$branch"
  cd "$worktree_path"
}

function git-log-jordan-graph-all-plus-origin-head() {
  git log-jordan-all-not-origin-head --color=never --format="format:%h" --branches HEAD | xargs -I{} git log-graph {} "$@" | command grep --color=never -A9 -E "HEAD|\/origin\/|\/heads\/|\/remotes\/|^[^*]*$|^[^*].*[*]" | less
}

function git-rebase-onto-merge-base-branch() {
  # Rebase A..B onto $(git merge-base A B).
  # If B was forked directly from A, then B' should have the same fork point as B. This can be useful for
  # squashing/linearizing the branch.
  # If B was forked from C which was forked from A, then B' could potentially be detached from C and have a new fork
  # point.
  A="$1"  # The base branch that B was forked from.
  B="$2"  # The branch to be rebased, which was forked from A.
  shift 2
  git rebase --onto "${A}...${B}" "${A}" "${B}" "$@"
}
alias   g-rebase-onto-merge-base-branch=git-rebase-onto-merge-base-branch
alias git-rebase-onto-merge-base-origin-HEAD-branch="git-rebase-onto-merge-base-branch origin/HEAD"
alias   g-rebase-onto-merge-base-origin-HEAD-branch="git-rebase-onto-merge-base-origin-HEAD-branch"
alias git-rebase-onto-merge-base-main-branch=git-rebase-onto-merge-base-origin-HEAD-branch
alias   g-rebase-onto-merge-base-main-branch=git-rebase-onto-merge-base-origin-HEAD-branch
#alias git-rebase-onto-merge-base-main-local-branch="git-rebase-onto-merge-base-branch main"
#alias   g-rebase-onto-merge-base-main-local-branch="git-rebase-onto-merge-base-main-local-branch"
#alias git-rebase-onto-merge-base-HEAD-branch="git-rebase-onto-merge-base-branch HEAD"
#alias   g-rebase-onto-merge-base-HEAD-branch="git-rebase-onto-merge-base-HEAD-branch"

function git-branch-current() {
  current=$(git branch-current)
  if [[ -z "$current" ]]; then
    current="HEAD"
  fi
  echo $current
}
alias g-branch-current=git-branch-current

function git-rebase-onto-merge-base-branch-current() {
  # Rebase A..$(git branch-current) onto $(git merge-base A $(git branch-current)).
  A="$1"  # The base branch that B was forked from.
  shift 1
  git-rebase-onto-merge-base-branch "${A}" "$(git-branch-current)" "$@"
}
alias   g-rebase-onto-merge-base-branch-current=git-rebase-onto-merge-base-branch-current
alias git-rebase-onto-merge-base-origin-HEAD-branch-current="git-rebase-onto-merge-base-branch-current origin/HEAD"
alias   g-rebase-onto-merge-base-origin-HEAD-branch-current="git-rebase-onto-merge-base-origin-HEAD-branch-current"
alias git-rebase-onto-merge-base-main-branch-current=git-rebase-onto-merge-base-origin-HEAD-branch-current
alias   g-rebase-onto-merge-base-main-branch-current=git-rebase-onto-merge-base-origin-HEAD-branch-current

function git-rebase-onto-onto-upstream-merge-base-3() {
  H="$1"
  A="$2"
  B="$3"
  shift 3
  git rebase --onto "${H}" $(git merge-base "${A}" "${B}") "${B}" "$@"
}
alias   g-rebase-onto-onto-upstream-merge-base-3=git-rebase-onto-onto-upstream-merge-base-3
alias git-rebase-onto-onto-upstream-merge-base-HEAD-3="git-rebase-onto-onto-upstream-merge-base-3 HEAD"
alias   g-rebase-onto-onto-upstream-merge-base-HEAD-3="git-rebase-onto-onto-upstream-merge-base-HEAD-3"
alias git-rebase-onto-onto-upstream-merge-base-origin-HEAD-3="git-rebase-onto-onto-upstream-merge-base-3 origin/HEAD"
alias   g-rebase-onto-onto-upstream-merge-base-origin-HEAD-3="git-rebase-onto-onto-upstream-merge-base-origin-HEAD-3"
alias git-rebase-onto-onto-upstream-merge-base-main-local-3="git-rebase-onto-onto-upstream-merge-base-3 main"
alias   g-rebase-onto-onto-upstream-merge-base-main-local-3="git-rebase-onto-onto-upstream-merge-base-main-local-3"
alias git-rebase-onto-onto-upstream-merge-base-main-3=git-rebase-onto-onto-upstream-merge-base-origin-HEAD-3
alias   g-rebase-onto-onto-upstream-merge-base-main-3=git-rebase-onto-onto-upstream-merge-base-origin-HEAD-3

function git-rebase-onto-onto-upstream-merge-base() {
  H="$1"
  B="$2"
  shift 2
  git-rebase-onto-onto-upstream-merge-base-3 "${H}" "${H}" "${B}" "$@"
}
alias   g-rebase-onto-onto-upstream-merge-base=git-rebase-onto-onto-upstream-merge-base
alias git-rebase-onto-onto-upstream-merge-base-HEAD="git-rebase-onto-onto-upstream-merge-base HEAD"
alias   g-rebase-onto-onto-upstream-merge-base-HEAD="git-rebase-onto-onto-upstream-merge-base-HEAD"
alias git-rebase-onto-onto-upstream-merge-base-origin-HEAD="git-rebase-onto-onto-upstream-merge-base origin/HEAD"
alias   g-rebase-onto-onto-upstream-merge-base-origin-HEAD="git-rebase-onto-onto-upstream-merge-base-origin-HEAD"
alias git-rebase-onto-onto-upstream-merge-base-main-local="git-rebase-onto-onto-upstream-merge-base main"
alias   g-rebase-onto-onto-upstream-merge-base-main-local="git-rebase-onto-onto-upstream-merge-base-main-local"
alias git-rebase-onto-onto-upstream-merge-base-main=git-rebase-onto-onto-upstream-merge-base-origin-HEAD
alias   g-rebase-onto-onto-upstream-merge-base-main=git-rebase-onto-onto-upstream-merge-base-origin-HEAD

function git-diff-tool-merge-base() {
  difftool="$1"
  A="$2"
  B="$3"
  shift 3
  git "${difftool}" "${A}...${B}" "$@"
}
alias   g-diff-tool-merge-base=git-diff-tool-merge-base
alias git-diff-merge-base="git-diff-tool-merge-base diff"
alias git-ddiff-merge-base="git-diff-tool-merge-base ddiff"
alias git-dft-merge-base="git-diff-tool-merge-base dft"

for tool in diff ddiff dft; do
  alias   "g-${tool}-merge-base"="git-${tool}-merge-base"

  alias "git-${tool}-merge-base-HEAD"="git-${tool}-merge-base HEAD"
  alias   "g-${tool}-merge-base-HEAD"="git-${tool}-merge-base-HEAD"
  alias "git-${tool}-merge-base-origin-HEAD"="git-${tool}-merge-base origin/HEAD"
  alias   "g-${tool}-merge-base-origin-HEAD"="git-${tool}-merge-base-origin-HEAD"
  alias "git-${tool}-merge-base-main-local"="git-${tool}-merge-base main"
  alias   "g-${tool}-merge-base-main-local"="git-${tool}-merge-base-main-local"
  alias "git-${tool}-merge-base-origin-HEAD"="git-${tool}-merge-base origin/HEAD"
  alias   "g-${tool}-merge-base-origin-HEAD"="git-${tool}-merge-base-origin-HEAD"
done

export gcnffdx="-nffdx"
export gcnffdx_force_execute="-ffdx"
export gldecorate="--decorate=full"
export glnot_HEAD="--not HEAD --not"
export glnot_origin_HEAD="--not origin/HEAD --not"
export glnot_main_local="--not main --not"
export glnot_main="$glnot_origin_HEAD"
export glgraph="--oneline --graph"
export gljordan="--author=jmoldow --author=Moldow --author=jormol"
export gcamend="--amend --reset-author -e"
export gcdifft="-c diff.external=difft -c \"core.pager='less -FRXISM'\""

if [ $(which delta) ]; then
  alias delta="delta --pager='less -RISM'"
  eval "$(delta --generate-completion bash)"
fi
if [ $(which rg) ]; then
  eval "$(command rg --generate=complete-bash)"
  if [ $(which delta) ]; then
    function rg {
      if echo "$@" | grep --quiet -E "((^| )[-][lc])|(--files)|(--count)"; then
        command rg "$@"
      else
        command rg --json -C 2 "$@" | delta
      fi
    }
  fi
  alias ripgrep=rg
  alias rgrep=rg
  for c in ripgrep rgrep; do
    eval "$(command rg --generate=complete-bash | sed -E -e "s/ rg$/ ${c}/g" -e "s/_rg/_${c}/g" -e "s/rg)/${c})/g" -e "s/rg[(]/${c}[(]/g" -e "s/'rg'/'${c}'/g" -e "s/\"rg\"/\"${c}\"/g")"
  done
fi
if [ $(which difft) ]; then
  export DFT_COLOR=always
  function difft {
    command difft "$@" | less
  }
fi

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
  eval "$(pyenv init --detect-shell bash)"
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
    eval "$(complete -p kubectl | sed -E -e "s/ kubectl$/ ${c}/g")"
  done
  if [ $(which kubectx) ]; then
    alias kx=kubectx
    alias ctx=kubectx
    for c in kx ctx; do
      eval "$(complete -p kubectx | sed -E -e "s/ kubectx$/ ${c}/g")"
    done
  fi
  if [ $(which kubens) ]; then
    alias kn=kubens
    alias ns=kubens
    for c in kn ns; do
      eval "$(complete -p kubens | sed -E -e "s/ kubens$/ ${c}/g")"
    done
  fi
fi

if [ $(which k9s) ]; then
  source <(k9s completion bash)
fi

if [ $(which helm) ]; then
  source <(helm completion bash)
fi

if [ $(which kustomize) ]; then
  source <(kustomize completion bash)
fi

if [ $(which gt) ]; then
  alias graphite=gt
  alias grphite=gt
  source <(gt completion)
  eval "$(complete -p gt | sed -E -e "s/ gt$/ graphite/g")"
  eval "$(complete -p gt | sed -E -e "s/ gt$/ grphite/g")"
fi

export KREW_ROOT="${XDG_DATA_HOME}/krew"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if [ $(which kubectx) ]; then
  function kubectx-current() {
    kubectx --current
  }
  alias  kx-current=kubectx-current
  alias ctx-current=kubectx-current
  function kubens-current() {
    kubens --current
  }
  alias kn-current=kubens-current
  alias ns-current=kubens-current
  function kubectx-env {
    env=$1
    current_namespace="$(kubens --current)"
    namespace="${2:-${current_namespace}}"
    if ! (kubectx --current | grep -q $env); then
      kubectx | command grep --color=never $env | head -n1 | xargs -r kubectx
      kubens $namespace || true
      kubectx --current | grep -q $env
    else
      if [[ "$(kubens --current)" != "$namespace" ]] ; then
        kubens $namespace || true
      else
        kubectx --current
        kubens --current
      fi
    fi
  }
  alias kx-env=kubectx-env
  alias ctx-env=kubectx-env
  function kubectx-dev {
    kubectx-env dev "$@"
  }
  alias kx-dev=kubectx-dev
  alias ctx-dev=kubectx-dev
  function kubectx-prod {
    kubectx-env prod "$@" || kubectx-env prd "$@"
  }
  alias kx-prod=kubectx-prod
  alias ctx-prod=kubectx-prod
  function kubectx-staging {
    kubectx-env staging "$@" || kubectx-env stage "$@" || kubectx-env stg "$@"
  }
  alias kx-staging=kubectx-staging
  alias ctx-staging=kubectx-staging
  function kubectx-sandbox {
    kubectx-env sandbox "$@" || kubectx-env sand "$@"
  }
  alias kx-sandbox=kubectx-sandbox
  alias ctx-sandbox=kubectx-sandbox
  function kubectx-ci {
    kubectx-env ci "$@"
  }
  alias kx-ci=kubectx-ci
  alias ctx-ci=kubectx-ci

  function kubectx-all() {
    orig_context=$(kubectx --current)
    echo $orig_context
    orig_namespace=$(kubens --current)
    echo $orig_namespace
    for fn in sandbox ci dev staging prod ; do
      "kubectx-${fn}"
      kubens $orig_namespace
      "$@"
    done
    kubectx $orig_context
    kubens $orig_namespace
  }
  alias kx-all=kubectx-all
  alias ctx-all=kubectx-all
fi

if [ $(which argocd) ]; then
  source <(argocd completion bash)
fi

if [ $(which docker) ]; then
  function docker-run() {
    docker run -ti \
      $(env | command grep --color=never -E '^((XDG_CONFIG_HOME|COLORTERM|LESS|LOGNAME|HOME|LANG|COLUMNS|CLICOLOR|TERM|USER|INPUTRC|EMAIL)|([A-Z][A-Z]+))[=][a-zA-Z0-9_/.~@-]{0,99}$' | command grep --color=never -vE "SHELL|EDITOR|PWD|DIR|FILE|HIST|TMP|OLD|PATH|COLUMNS|^GO|SHLVL" | xargs -I% echo "--env" % | xargs) \
      -v /var/run/docker.sock:/var/run/docker.sock \
      $(echo "$(pwd)/" | grep -q -oE "^$HOME/*$" || echo -v "$(pwd)":"$(pwd)" -v "$(pwd)":"/pwd" -w "$(pwd)") \
      -v "$HOME/.config":"$HOME/.config" \
      -v "$HOME/.config":"/root/.config" \
      -v "$XDG_CONFIG_HOME":"$XDG_CONFIG_HOME" \
      -v "$HOME/jmoldow-bash-profile:$HOME/jmoldow-bash-profile" \
      -v "$HOME/jmoldow-bash-profile:/root/jmoldow-bash-profile" \
      -v "$HOME/jmoldow:$HOME/jmoldow" \
      -v "$HOME/jmoldow:/root/jmoldow" \
      -v "$HOME/git/jmoldow:$HOME/git/jmoldow" \
      -v "$HOME/git/jmoldow:/root/git/jmoldow" \
      $@
  }
  function docker-run-rm() {
    docker-run --rm $@
  }
  function docker-dive() {
    dive_image="wagoodman/dive:latest"
    docker pull "$dive_image" || true
    docker-run-rm ${CI:+--env "CI=${CI}"} \
      "$dive_image" --config "$XDG_CONFIG_HOME/dive.yaml" --ci-config "$XDG_CONFIG_HOME/dive-ci.yaml"  $@
  }
  eval "$(complete -p docker | sed -E -e "s/ docker$/ docker-dive/g")"
  function docker-dive-image-archive() {
    image="$1"
    shift 1
    docker image pull "$image" || true
    filename="image-saved-for-dive.tar"
    docker image save -o "$filename" "$image"
    docker-dive "/pwd/${filename}" --source docker-archive $@
  }
  alias dive=docker-dive-image-archive
  function docker-dive-build() {
    docker-dive build $@
  }
  function docker-dive-build-here() {
    docker-dive-build $@ .
  }
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

export PANTS_COLORS=true
alias pants="PANTS_COLORS=true pants --colors"

#export PS1="\u@\h \W \$(kprompt) \[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

export MANPATH="${MANPATH:-}:/usr/local/opt/erlang/lib/erlang/man:"

export PATH="$PATH:/usr/local/opt/mysql-client@5.7/bin"
export PATH=/usr/local/opt/curl/bin:$PATH

if [ $(which aws) ]; then
  if [ -f ~/.aws/config ]; then
    export AWS_PROFILE="$(grep --color=never -E "^[[]profile .*dev" ~/.aws/config | head -n1 | sed -E -e "s/^.*profile //g" -e "s/[]]//g")"
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
