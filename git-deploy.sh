#!/bin/sh
# Git push then pull over ssh
#
# Supposing you have these environments on the same host:
#  project/origin.git/
#  project/dev/.git
#  project/prod/.git
# 
# Add this to your bin/ file for example then to your git config:
#   $ git config --global alias.deployd '!sh ~/bin/git-deploy.sh'
#
# You can then:
#   $ git deploy dev
#   $ git deploy prod

ORIGIN=`git config --get remote.origin.url`

HOST=`echo $ORIGIN | sed s/:.*//`
DIR=`echo $ORIGIN | sed s/.*://`
ENV=$1
[ "$ENV" == "" ] && ENV=dev

git push
ssh $HOST "cd $DIR/../$ENV && git pull"
