#! /bin/bash
cd /my-blog
echo "☆☆☆☆☆ your git repo is [$PULL_GIT_REPO] ; branch is [$PULL_BRANCH].☆☆☆☆☆"
## 如果配置了代理则设置代理
if [ "$PROXY" != '' ]; then
    echo "you proxy setting is [$PROXY]."
    git config --global http.proxy "'$PROXY'"
fi
git clone -v --progress --depth=1 -b $PULL_BRANCH $PULL_GIT_REPO blog && echo "clone repo success!!!" || exit 1
## 取消代理设置
git config --global --unset http.proxy

if [ "$MODE" == 'deploy' ]; then
    sh ./deploy.sh
fi

if [ "$MODE" == 'public' ]; then
    sh ./public.sh
fi

if [ "$MODE" == 'all' ]; then
    sh ./deploy.sh
    sh ./public.sh
fi

/bin/bash