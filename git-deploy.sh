#!/bin/sh
# Git push then pull over ssh
#
# Supposing you have these environments on the same ssh git remote:
#   project/origin.git
#   project/dev/.git
#   project/prod/.git
#
# You can then push the current branch and pull it in dev/ and prod/ by doing:
#   $ git deploy dev
#   $ git deploy prod
#
# Installation with ~/bin in your $PATH:
#   $ curl http://gist.github.com/raw/407687/git-deploy.sh > ~/bin/git-deploy
#   $ chmod +x ~/bin/git-deploy
#   $ git config --global alias.deploy '!git-deploy'

set -e

REMOTE='origin'
ENV=${1:-dev} # first argument or default to dev

BRANCH=`git branch 2> /dev/null | sed -n '/^\*/s/^\* //p'`
REMOTE_URL=`git config --get remote.$REMOTE.url`
HOST=${REMOTE_URL%%:*}
DIR=${REMOTE_URL#*:}
ENV_DIR="${DIR%/*}"/$ENV


echo "* Sending $BRANCH"
git push origin $BRANCH

ssh -T $HOST "

set -e

cd $ENV_DIR
git fetch $REMOTE

CURRENT_BRANCH=\`git branch 2> /dev/null | sed -n '/^\*/s/^\* //p'\`
(git branch 2> /dev/null | grep -n '^  $BRANCH') && HAS_BRANCH=1 || HAS_BRANCH=0

# Change branch
if [ $BRANCH != \$CURRENT_BRANCH ]; then

  # Create remote tracked branch
  if [ \$HAS_BRANCH != 1 ]; then
    echo '* Creating $BRANCH branch in $ENV'
    git checkout -t $REMOTE/$BRANCH

  # Switch to it
  else
    echo '* Switching to $BRANCH branch in $ENV'
    git checkout $BRANCH --
  fi
fi

# Pull
echo '* Pulling $BRANCH in $ENV'
git merge $REMOTE/$BRANCH --ff-only
"


[ -f __scripts/deploy ] && __scripts/deploy "$ENV"