case $- in
    *i*) ;;
      *) return;;
esac

HISTFILE=~/.histfile.zsh
HISTSIZE=1000000
SAVEHIST=10000000
setopt share_history


if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


source ~/powerlevel10k/powerlevel10k.zsh-theme

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word


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

gi(){
    if [[ $@ == "tpush" ]]; then
        git push
    fi
}




killp(){ 
    kill -9 $(lsof -t -i:"$@" -sTCP:LISTEN) 
}

sha-384(){
    cat "$1"| openssl dgst -sha384 -binary | openssl base64 -A
}

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

alias gc='git checkout'

alias gf='git fetch'

alias gd='git diff'

alias gdiff='git diff'

alias gpush='git push'

alias gpull='git pull'

alias gs='git status'

alias cls=clear

alias shut10='sleep 10; shutdown -h now'

alias shutnow='shutdown -h now'

alias shut='shutdown +1'

alias a='shutdown -c'

alias empty='git commit --allow-empty -m "Trigger deployment" && push'

alias lock='gnome-screensaver-command -l'

alias c="xclip && v | xclip -selection clipboard"

alias v="xclip -o"

alias vrun="v | sh -i"

alias folders='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'

alias ls='ls -h --color=auto'

alias reload="source ~/.zshrc"

alias rl=reload

alias "ocAll"=oc_apply_all

alias "gcrename"="git commit --allow-empty --amend -m"

alias "gr"=grename

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


alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias cf=config

export UID GID

# Add ~/.local/bin to path
export PATH="$HOME/.local/bin:$PATH"

## asdf
. $HOME/.asdf/asdf.sh

fpath=(${ASDF_DIR}/completions $fpath)
plugins=(asdf)


# Java
. ~/.asdf/plugins/java/set-java-home.zsh

## Maven
export M2_HOME="$HOME/.local/bin/apache-maven/apache-maven-3.9.8"
export M2=$M2_HOME/bin 
export MAVEN_OPTS="-Xms256m -Xmx512m" 
export PATH=$M2:$PATH


# Haskell
[ -f "/home/yanickminder/.ghcup/env" ] && source "/home/yanickminder/.ghcup/env" # ghcup-env

# Thefuck
eval $(thefuck --alias)

## Fuzzyfinder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
autoload -Uz compinit && compinit


# OC client
if [ $commands[oc] ]; then
  source <(oc completion zsh)
  compdef _oc oc
fi



# Load Angular CLI autocompletion.
source <(ng completion script)




