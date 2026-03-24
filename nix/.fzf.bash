# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  PATH="$HOME/.fzf/bin${PATH:+:${PATH}}"
fi

eval "$(fzf --bash)"
