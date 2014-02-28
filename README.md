$ git deploy
============

Git push then pull over ssh.

How
---

Supposing you have these environments on the same ssh git remote:

    thatproject/origin.git
    thatproject/dev/.git
    thatproject/prod/.git

You can then push the current branch and pull it in `dev/` and `prod/` by doing:

    $ git deploy dev
    $ git deploy prod

It will guess those folder names based on the `origin` remote.


Install
-------

Make sure `~/bin` is in your `$PATH`, then:

```sh
$ curl https://raw.github.com/sunny/git-deploy/master/git-deploy.sh > ~/bin/git-deploy
$ chmod +x ~/bin/git-deploy
$ git config --global alias.deploy '!git-deploy'
```

Update
------

```sh
$ curl https://raw.github.com/sunny/git-deploy/master/git-deploy.sh > ~/bin/git-deploy
```
