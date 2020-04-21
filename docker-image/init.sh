#! /bin/bash
service nginx start
service fcgiwrap start
cd /my-blog
echo "your git repo is [$GIT_REPO] ; branch is [$BRANCH]"
git clone -b $BRANCH --progress $GIT_REPO blog
cd blog
cnpm install -d
hexo g --watch --debug | tee -a /my-blog/logs/genrate.log