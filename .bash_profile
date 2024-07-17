#export LESS="-RSMsi"
#export LESS="-RM"

export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
export XDG_STATE_HOME=~/.local/state

# <https://www.reddit.com/r/commandline/comments/4m0s58/how_and_why_to_log_your_entire_bash_history/d3rqo3a>
#export PROMPT_COMMAND='history -a'
export HISTSIZE=9999999999999
export HISTFILESIZE=999999999
export HISTTIMEFORMAT='%F %T '
#export HISTCONTROL="erasedups:ignoreboth"
export HISTIGNORE="ls:ll:pwd:exit:su:clear:reboot:history:bg:fg"
export HISTFILE=$XDG_DATA_HOME/bash_history
export INPUTRC=$XDG_CONFIG_HOME/readline/inputrc

export COLUMNS

alias less='less -IRS'
alias diff='diff --color=always -U9'

# "Fix" for <https://github.com/jqlang/jq/issues/2001> until jq 1.7 is released to Debian.
export JQ='env --split-string --ignore-environment TZ=UTC jq'
alias jq="$JQ"

export GOENV=$XDG_CONFIG_HOME/go/env
export GOPATH=$(go env GOPATH || echo "$XDG_STATE_HOME/go-path-build/go")
export PATH=$PATH:$(go env GOBIN):$GOPATH/bin:$GOPATH:$HOME/go/bin:$HOME/go:$(go env GOTOOLDIR):$(go env GOROOT)/bin:$(go env GOROOT)

export HOMEBREW_NO_AUTO_UPDATE=1
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
if [ $(which brew) ]; then
  if [ -f $(brew --prefix 2>/dev/null)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi
# curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/git-completion.bash
# curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/git-prompt.sh
source ~/git-completion.bash
source ~/git-prompt.sh
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
java8
# export JAVA_OPTS="-XX:+UseG1GC -Xmx4g -Xss4m"  # -XX:MaxMetaspaceSize=768m"
export JAVA_OPTS="-XX:+UseG1GC -Xmx6g -Xss8m"  # -XX:MaxMetaspaceSize=768m"

(ls $XDG_STATE_HOME/pyvenv/pyenv/pyenv*/bin 2>/dev/null | grep -q bin) && export PATH=$PATH:$(ls $XDG_STATE_HOME/pyvenv/pyenv/pyenv*/bin 2>/dev/null | grep bin | sort -g -r | xargs | sed "s/ //g")

#export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

ssh-add ~/.ssh/id_rsa ~/.ssh/github_rsa 2>/dev/null

alias pyenv-init='eval "$(pyenv init -)"'

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
fi

#export PS1="\u@\h \W \$(kprompt) \[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

export MANPATH="$MANPATH:/usr/local/opt/erlang/lib/erlang/man:"

export PATH="$PATH:/usr/local/opt/mysql-client@5.7/bin"
export PATH=/usr/local/opt/curl/bin:$PATH

find_quote_spaces() {
  find "$@" | sed -E -e 's#(.*)#"\1"#g' -e "s# #\\ #g"
}

find_quote_spaces_all() {
  find . | sed -E 's/(.*)/"\1"/g' | sed -E "s/ /\\ /g"
}
