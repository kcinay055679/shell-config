# --- 1. Powerlevel10k Instant Prompt (Must be at the top) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- 2. Path & Environment (MOVED UP) ---
# IMPORTANT: These must be set BEFORE plugins load so plugins can find your tools.
export UID GID
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PLANTUML_JAR=~/.local/bin/plantuml.jar
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# Path

# --- 3. Oh-My-Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"

# Set theme back to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# History
HISTFILE=~/.histfile.zsh
HISTSIZE=1000000
SAVEHIST=10000000
setopt share_history
setopt APPEND_HISTORY

# --- 4. Plugins ---
ZVM_INIT_MODE=sourcing
# plugins must be defined before sourcing oh-my-zsh
plugins=(
  mise
  zsh-vi-mode
  ng
  git
  kubectl
  helm
  docker
  docker-compose
  zsh-autosuggestions      # Should be second to last
  fast-syntax-highlighting # Should be strictly last
)

# --- 5. Load Oh-My-Zsh ---
source $ZSH/oh-my-zsh.sh
VI_MODE_SET_CURSOR=true
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_CLIPBOARD_COPY_CMD='wl-copy'
ZVM_CLIPBOARD_PASTE_CMD='wl-paste'
# --- 6. User Configuration & Bindings ---
EDITOR=nvim
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- 7. Custom Functions ---
s(){
    echo "$(history -p '!!')"
    if [[ $# == 0 ]]; then sudo $(history -p '!!'); else sudo "$@"; fi
}

cd_mkdir(){ mkdir "$1" && cd "$1"; }

extract (){
    local x
    ee() { echo "$@"; $1 "$2"; }
    for x in "$@"; do
        [[ -f $x ]] || continue
        case "$x" in
            *.tar.bz2 | *.tbz2 )  ee "tar xvjf" "$x"  ;;
            *.tar.gz | *.tgz )    ee "tar xvzf" "$x"  ;;
            *.bz2 )               ee "bunzip2" "$x"   ;;
            *.rar )               ee "unrar x" "$x"   ;;
            *.gz )                ee "gunzip" "$x"    ;;
            *.tar )               ee "tar xvf" "$x"   ;;
            *.zip )               ee "unzip" "$x"     ;;
            *.Z )                 ee "uncompress" "$x" ;;
            *.7z )                ee "7z x" "$x"      ;;
        esac
    done
}

oc_apply_all(){
    fileString="$(find . -type f -name '*.yaml')"
    files=($(echo "$fileString" | tr '' '\n'))
    for i in "${files[@]}"; do oc apply -f $i; done
}

get_container_name() {
    [ -n "$1" ] && docker ps | grep "$1" | rev | cut -d ' ' -f 1 | rev
}

# Docker Utils
dcrv(){ docker compose down $@ -v && docker compose up -d $1; }
drmc() { docker rm -f $(docker ps -aq); }
armageddon() {
    drmc
    docker network prune -f
    docker volume rm  $(docker volume ls --filter dangling=true -q)
    docker container prune -f
}

newestContainer(){
    docker ps -a --no-trunc --filter "status=running" --format "{{.Names}}" | head -n 1
}

dcexec(){
    DEFAULT_CONTAINER=$(newestContainer)
    DEFAULT_COMMAND="/bin/bash"
    container="${1:-$DEFAULT_CONTAINER}"
    command="${2:-$DEFAULT_COMMAND}"
    sh -c "docker compose exec -it $container $command"
}

dcexecf() {
    DEFAULT_CONTAINER=$(newestContainer)
    DEFAULT_APPLICATION="bash"
    DOCKER_TARGET_PATH='/home/\$(ls /home | head -n 1)'
    container="${1:-$DEFAULT_CONTAINER}"
    application="${2:-$DEFAULT_APPLICATION}"
    docker compose cp -a ~/dockerHome $container:/tmp
    custom_command="cp -r /tmp/dockerHome/. $DOCKER_TARGET_PATH"
    command="sh -c \"$custom_command && $application\""
    sh -c "docker compose exec -it $container $command"
}

showp(){ lsof -i:"$@"; }
killp(){ kill -9 $(lsof -t -i:"$@" ); }
sha-384(){ echo "sha384-$(cat "$1" | openssl dgst -sha384 -binary | openssl base64 -A)" | c | v; }

gh-cancel-runs() {
  local actor_filter=""
  if [ -n "$1" ]; then actor_filter="-u $1"; fi
  local run_ids=$( { \
    gh run list --limit 100 --status in_progress $actor_filter --json databaseId -q '.[].databaseId'; \
    gh run list --limit 100 --status queued $actor_filter --json databaseId -q '.[].databaseId'; \
  } )
  echo "$run_ids" | xargs -r -n1 gh run cancel
}

chats() {
    PROFILE="messengers"
    URLS=("https://chat.puzzle.ch" "https://web.whatsapp.com" "https://teams.microsoft.com/v2/" "https://outlook.office.com")
    google-chrome-stable --profile-directory="$PROFILE" "${URLS[@]}"
}

# --- 8. Aliases ---
alias "sha384"="sha-384"
alias "sha"="sha-384"
alias "home"='cd ~'
alias "cd.."='cd ..'
alias ".."='cd ..'
alias "..."='cd ../..'
alias "...."='cd ../../..'
alias "....."='cd ../../../..'
alias "mkdircd"="cd_mkdir"
alias "mc"="mkdircd"
alias "cm"="mc"
alias ll='ls -alF'

# Git
alias g="git"
alias gi="git"
alias gc='git checkout'
alias gf='git fetch'
alias gd='git diff'
alias gdiff='git diff'
alias gpush='git push'
alias gpull='git pull'
alias gs='git status'
alias gac='git aa && git commit -m'
alias gacp='git aa && git commit -m && git push'
alias empty='git commit --allow-empty -m "Trigger deployment" && push'
alias gcrename="git commit --allow-empty --amend -m"
alias gr=grename
alias xg='head -1 | xargs git'
alias prco="gh pr checkout"
alias ghco="gh pr checkout"

# System
alias cls=clear
alias shut10='sleep 10; shutdown -h now'
alias shutnow='shutdown -h now'
alias shut='shutdown +1'
alias a='shutdown -c'
alias lock='gnome-screensaver-command -l'
alias c="wl-copy"
alias v="wl-paste"
alias vrun="v | sh -i"
alias folders='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias ls='ls -h --color=auto'
alias reload="exec zsh"
alias rl=reload
alias xa=xargs
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias df=dotfiles
alias "dfu"="df add -u && df cm 'update existing files' && df push"
alias "df-u"=dfu
alias "df-files"="df ls-files"
alias dff="df-files"
alias n=nvim
# Docker
alias "d"="docker"
alias "dc"="docker compose"
alias "dps"="docker ps"
alias "dcu"="docker compose up"
alias "dcd"="docker compose down"
alias "dcdv"="docker compose down -v"
alias "dcud"="docker compose up -d"

# Yarn
alias "yarnr"="yarn cache clean && rm -rf node_modules && yarn"
alias "yarnrst"="yarnr && npm start"
alias "yarnrs"="yarnrst"

# Cryptopus
alias "cprep"="dc exec ember yarn build --prod && dc exec rails ./bin/prepare-frontend.sh"
alias "cpreptest"="cprep && dc exec -it rails bash"
alias "cprept"="cpreptest"

# Other
alias "bfg"="java -jar /etc/bfg/bfg-1.14.0.jar"
alias "vpn:bls"="sudo -E gpclient connect --browser default https://access-partner.bls.ch --hip"
alias "brst"="echo 'Key is : PMWnGpkpwVBKoNz3a3m6' && BrowserStackLocal --key PMWnGpkpwVBKoNz2a3m6 --force-local"
alias "brstlo"=brst
alias "brStLo"=brst
alias cd="z"

alias mice='for i in {1..$COLUMNS}; do printf "\r%*s" $i ".=.>"; sleep 0.01; done; tput cr; tput el; mise'
alias pp="pnpm"
alias p="pnpm"
alias m=mise
alias ls="eza --icons=always --group-directories-first"
alias ll="eza -la --icons=always --group-directories-first --git --octal-permissions"
alias lt="eza --tree --level=2 --icons=always --group-directories-first"
alias screenshot='grim -g "$(slurp)" - | wl-copy --type image/png'
alias zshrc="n ~/.zshrc"

alias gitconfig="n ~/.gitconfig"

alias kns='kubectl config set-context --current --namespace'
alias kc="k config use-context"

alias m=mise
# --- 9. Final Loads ---
fpath=($fpath ~/.oh-my-zsh/completions)

# Java & Maven
export MAVEN_OPTS="-Xmx8g" 
# Thefuck
eval $(thefuck --alias)


# Fuzzyfinder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Zoxide (must be last)
eval "$(zoxide init zsh)"

eval "$(~/.local/bin/mise activate zsh)"

export EDITOR=$(where nvim)


# pnpm
export PNPM_HOME="/home/yminder/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

source <(ng completion script) 

# opencode
export PATH=/home/yminder/.opencode/bin:$PATH
