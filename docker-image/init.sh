#! /bin/bash
cd /my-blog
echo "☆☆☆☆☆ your git repo is [$GIT_REPO] ; branch is [$BRANCH].☆☆☆☆☆"
## 如果配置了代理则设置代理
if [ "$PROXY" != '' ]; then
    echo "you proxy setting is [$PROXY]."
    git config --global http.proxy "'$PROXY'"
fi
git clone -v --progress --depth=1 -b $BRANCH $GIT_REPO blog && echo "clone repo success!!!" || exit 1
## 取消代理设置
git config --global --unset http.proxy
cd blog
cnpm install -d
hexo g --debug | tee /my-blog/logs/genrate.log
tail -f -n 500 /my-blog/logs/genrate.log