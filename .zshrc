case $- in
    *i*) ;;
      *) return;;
esac

HISTFILE=~/.histfile.zsh
HISTSIZE=1000000
SAVEHIST=10000000
setopt share_history
setopt APPEND_HISTORY

EDITOR=micro

# source ~/zsh-autocomplete/zsh-autocomplete.plugin.zsh
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom" 
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


source ~/powerlevel10k/powerlevel10k.zsh-theme

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word
# bindkey -M menuselect  '^[[D' .backward-char  '^[OD' .backward-char
# bindkey -M menuselect  '^[[C'  .forward-char  '^[OC'  .forward-char


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#!/bin/zsh
s(){ # do sudo, or sudo the last command if no argument given
    echo "$(history -p '!!')"
    if [[ $# == 0 ]]; then
        sudo $(history -p '!!')
    else
        sudo "$@"
    fi
}


cd_mkdir(){
    mkdir "$1"
    cd "$1"
}

extract (){ # extract files. Ignore files with improper extensions.
    local x
    ee() { # echo and execute
        echo "$@"
        $1 "$2"
    }
    for x in "$@"; do
        [[ -f $x ]] || continue
        case "$x" in
            *.tar.bz2 | *.tbz2 )    ee "tar xvjf" "$x"  ;;
            *.tar.gz | *.tgz ) ee "tar xvzf" "$x"   ;;
            *.bz2 )             ee "bunzip2" "$x"   ;;
            *.rar )             ee "unrar x" "$x"   ;;
            *.gz )              ee "gunzip" "$x"    ;;
            *.tar )             ee "tar xvf" "$x"   ;;
            *.zip )             ee "unzip" "$x"     ;;
            *.Z )               ee "uncompress" "$x" ;;
            *.7z )              ee "7z x" "$x"      ;;
        esac
    done
}

oc_apply_all(){
    fileString="$(find . -type f -name '*.yaml')"
    files=($(echo "$fileString" | tr '' '\n'))

    for i in "${files[@]}" 
    do
        oc apply -f $i
    done
}



get_container_name() {
    [ -n "$1" ] && docker ps | grep "$1" | rev | cut -d ' ' -f 1 | rev
}

dcr(){
    docker compose down $@ && docker compose up -d $1
}

dcrv(){
    docker compose down $@ -v && docker compose up -d $1
}

drmc() {
    docker rm -f $(docker ps -aq)
}

armageddon() {
    drmc
    docker network prune -f
    # docker rmi -f $(docker images --filter dangling=true -qa)
    docker volume rm  $(docker volume ls --filter dangling=true -q)
    docker container prune -f
    # docker rmi -f $(docker images -qa)
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

# gi() {
#     if [[ $@ == "tpush" ]]; then
#         git push
#     fi
# }
 
showp(){ 
    lsof -i:"$@" 
}

killp(){ 
    kill -9 $(lsof -t -i:"$@" ) 
}

sha-384(){
   echo "sha384-$(cat "$1" | openssl dgst -sha384 -binary | openssl base64 -A)" | c | v
}

gh-cancel-runs() {
  local actor_filter=""
  if [ -n "$1" ]; then
    actor_filter="-u $1"
  fi

  local run_ids=$( { \
    gh run list --limit 100 --status in_progress $actor_filter --json databaseId -q '.[].databaseId'; \
    gh run list --limit 100 --status queued $actor_filter --json databaseId -q '.[].databaseId'; \
  } )

  echo "$run_ids" | xargs -r -n1 gh run cancel
}

chats() {
	# Specifies the directory name for the Chrome profile.
	# Using a separate profile keeps cookies, history, and extensions isolated.
	PROFILE="messengers"
	
	# Creates an array of URLs to be opened.
	# Using an array makes the list of sites easy to manage.
	URLS=(
	  "https://chat.puzzle.ch"
	  "https://web.whatsapp.com"
	  "https://teams.microsoft.com/v2/"
	  "https://outlook.office.com"
	)
	
	# --- Script Logic ---
	# This command launches a single new Chrome window using the specified profile.
	# It opens all the URLs from the URLS array, each in its own tab.
	# The key change is using "${URLS[@]}" to ensure every URL in the array is passed as an argument.
	google-chrome-stable \
	  --profile-directory="$PROFILE" \
	  "${URLS[@]}"
}

alias "sha384"="sha-384"

alias "sha"="sha-384"

# navigation
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



# git
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

# System
alias cls=clear

alias shut10='sleep 10; shutdown -h now'

alias shutnow='shutdown -h now'

alias shut='shutdown +1'

alias a='shutdown -c'

alias lock='gnome-screensaver-command -l'

alias c="xclip && v | xclip -selection clipboard"

alias v="xclip -o"

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


# docker aliases

alias "d"="docker"

alias "dc"="docker compose"


alias "dps"="docker ps"

alias "dcu"="docker compose up"

alias "dcd"="docker compose down"

alias "dcdv"="docker compose down -v"

alias "dcud"="docker compose up -d"

# yarn aliases
alias "yarnr"="yarn cache clean && rm -rf node_modules && yarn"

alias "yarnrst"="yarnr && npm start"

alias "yarnrs"="yarnrst"

# Cryptopus aliases

alias "cprep"="dc exec ember yarn build --prod && dc exec rails ./bin/prepare-frontend.sh"

alias "cpreptest"="cprep && dc exec -it rails bash"

alias "cprept"="cpreptest"

#other

alias "bfg"="java -jar /etc/bfg/bfg-1.14.0.jar"
alias "vpn:bls"="sudo -E gpclient connect --browser default https://access-partner.bls.ch --hip"
alias "brst"="echo 'Key is : PMWnGpkpwVBKoNz3a3m6' && BrowserStackLocal --key PMWnGpkpwVBKoNz3a3m6 --force-local"
alias "brstlo"=brst
alias "brStLo"=brst

alias cd="z"

export UID GID

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PLANTUML_JAR=~/.local/bin/plantuml.jar

## asdf
fpath=(${ASDF_DIR}/completions $fpath ~/.oh-my-zsh/completions)

plugins=(colorize git nodejs python ruby rust terraform kubectl helm aws gcloud kubectx kubens docker docker-compose zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)
#plugins=(colorize git nodejs python ruby rust terraform kubectl helm aws gcloud kubectx kubens docker docker-compose)
ASDF_DATA_DIR=/home/yminder/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# Java
. ~/.asdf/plugins/java/set-java-home.zsh

## Maven
export MAVEN_OPTS="-Xms256m -Xmx512m" 


# Thefuck
eval $(thefuck --alias)

## Fuzzyfinder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
 autoload -Uz compinit && compinit


# OC client
# if [ $commands[oc] ]; then
  # source <(oc completion zsh)
  # compdef _oc oc
#fi



# Load Angular CLI autocompletion.
source <(ng completion script)


eval "$(zoxide init zsh)"
