#!/bin/sh
# Git push then pull over ssh
#
# Supposing you have these environments on the same git host:
#   project/origin.git/
#   project/dev/.git
#   project/prod/.git
#
# You can then push in origin/ and pull in dev/ or prod/ by doing:
#   $ git deploy prod
#
# Installation with ~/bin in your $PATH:
#   $ curl http://gist.github.com/raw/407687/git-deploy.sh > ~/bin/git-deploy
#   $ chmod +x ~/bin/git-deploy
#   $ git config --global alias.deploy '!git-deploy'

set -e

ORIGIN=`git config --get remote.origin.url`

HOST=${ORIGIN%%:*}
DIR=${ORIGIN#*:}
ENV=$1
[ "$ENV" == "" ] && ENV=dev

git push origin
ssh $HOST "cd $DIR/../$ENV && git pull --ff-only"

# Optionnal per-project deploy script
[ -f __scripts/deploy ] && __scripts/deploy "$ENV"
