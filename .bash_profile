#export LESS="-RSMsi"
#export LESS="-RM"

# <https://www.reddit.com/r/commandline/comments/4m0s58/how_and_why_to_log_your_entire_bash_history/d3rqo3a>
#export PROMPT_COMMAND='history -a'
export HISTSIZE=9999999999999
export HISTFILESIZE=999999999
export HISTTIMEFORMAT='%F %T '
#export HISTCONTROL="erasedups:ignoreboth"
export HISTIGNORE="ls:ll:pwd:exit:su:clear:reboot:history:bg:fg"
export HISTFILE=~/.bash_history

export HOMEBREW_NO_AUTO_UPDATE=1
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
# curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/git-completion.bash
source ~/git-completion.bash
command -v __git_ps1 > /dev/null
if [ 0 -eq 0 ]; then
   export GIT_PS1_SHOWDIRTYSTATE=
   export GIT_PS1_SHOWUPSTREAM="auto"
   # Tweak this as per your needs
   export PS1='[\u@\h \W]$ '
fi

export WORKON_HOME=~/.virtualenvs
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

export PATH=$PATH:$(ls /Users/jmoldow/.pyvenv/pyenv/pyenv*/bin | grep bin | sort -g -r | xargs | sed "s/ //g")

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

source <(kubectl completion bash)

#export PS1="\u@\h \W \$(kprompt) \[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

export MANPATH="$MANPATH:/usr/local/opt/erlang/lib/erlang/man:"

export PATH="$PATH:/usr/local/opt/mysql-client@5.7/bin:"
export PATH=/usr/local/opt/curl/bin:$PATH

find_quote_spaces() {
  find . -type f | sed -E 's/(.*)/"\1"/g' | sed -E "s/ /\\ /g"
}
