#!/bin/bash
# Git push then pull over ssh
# https://github.com/sunny/git-deploy

set -e

info(){
  echo -e "* \033[1m""$@""\033[0m"
}

REMOTE=${GIT_DEPLOY_REMOTE:-origin} # default remote is called "origin"
ENV=${1:-dev} # first argument or default to dev

# For local scripts before deploy (knock, for example)
if [ -f __scripts/deploy_before ]; then
  info "__scripts/deploy_before $ENV"
  __scripts/deploy_before "$ENV"
fi

BRANCH=`git branch 2> /dev/null | sed -n '/^\*/s/^\* //p'`
REMOTE_URL=`git config --get remote.$REMOTE.url`

if [[ $string == "ssh://"*":"* ]]; then
  REMOTE_URL="${REMOTE_URL#ssh://}"
  HOST="${REMOTE_URL%%/*}"
  DIR="/${REMOTE_URL#*/}"
else
  HOST="${REMOTE_URL%%:*}"
  DIR="${REMOTE_URL#*:}"
fi

ENV_DIR="${DIR%/*}"/$ENV

info "Sending $BRANCH"
git push $REMOTE HEAD

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

  # Launch post-merge
  [ -x .git/hooks/post-merge ] && .git/hooks/post-merge

# Pull
else
  echo '* Pulling $BRANCH in $ENV'
  git merge $REMOTE/$BRANCH --ff-only
fi
"

# For compile scripts (Compass, CoffeeScript, etc…)
if [ -f __scripts/compile ]; then
  info "__scripts/compile $ENV"
  ssh -T $HOST "cd $ENV_DIR && __scripts/compile $ENV"
fi


# For local extra deploy scripts (database, for example)
if [ -f __scripts/deploy ]; then
  info "__scripts/deploy $ENV"
  __scripts/deploy "$ENV"
fi

info "Tag $ENV"
git tag -f $ENV
git push -f $REMOTE $ENV

echo "👍"
