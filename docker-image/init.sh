#! /bin/bash
cd /my-blog
echo "☆☆☆☆☆ your git repo is [$GIT_REPO] ; branch is [$BRANCH]. ☆☆☆☆☆"
git clone -v --progress -b $BRANCH $GIT_REPO blog && echo "clone repo success!!!" || exit 1
cd blog
cnpm install -d
hexo g --debug | tee /my-blog/logs/genrate.log
tail -f -n 500 /my-blog/logs/genrate.log