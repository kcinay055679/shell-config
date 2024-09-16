# Setup fzf
# ---------
if [[ ! "$PATH" == */home/yminder/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/yminder/.fzf/bin"
fi

eval "$(fzf --bash)"
