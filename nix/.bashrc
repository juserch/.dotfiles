# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize

# Completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Shared config
[ -f ~/.chrc ] && source ~/.chrc
