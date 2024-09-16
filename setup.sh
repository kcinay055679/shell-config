cd ~
GIT_NAME=$(git config user.name)
GIT_EMAIL=$(git config user.email)

echo ".cfg" >> .gitignore
git clone --bare git@github.com:kcinay055679/shell-config.git $HOME/.cfg

config(){
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

cf(){
   config $@
}

cfco(){
  cf checkout -- $(cf diff --name-only | grep -E -v "README.md|setup.sh")
}

mkdir -p .config-backup
cfco
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    cfco 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
cfco
config config status.showUntrackedFiles no
git config --global user.name $GIT_NAME
git config --global user.email $GIT_EMAIL