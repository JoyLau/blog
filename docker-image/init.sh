#! /bin/bash
cd /my-blog
echo "☆☆☆☆☆ setting your git config, email: [$GIT_USER_EMAIL] ; name: [$GIT_USER_NAME].☆☆☆☆☆"
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

## 如果配置了代理则设置代理
if [[ $PROXY != '' ]]; then
  echo "setting your git proxy [$PROXY]."
  git config --global http.proxy "'$PROXY'"
fi

## 如果 MODE 包含字符串 deploy
if [[ $MODE == *deploy* ]]; then
  if [ ! -d "blog" ]; then
    echo "☆☆☆☆☆ your pull git repo is [$PULL_GIT_REPO] ; branch is [$PULL_BRANCH].☆☆☆☆☆"
    git clone -v --progress --depth=1 -b $PULL_BRANCH $PULL_GIT_REPO blog && echo "clone repo success!!!" || exit 1
  fi
  cd /my-blog/blog/
  cnpm install -d
  bash /my-blog/bash/deploy.sh -v
fi

## 如果 MODE 包含字符串 public
if [[ $MODE == *public* ]]; then
  echo "☆☆☆☆☆ your public git repo is [$PUBLIC_GIT_REPO] ; branch is [$PUSH_BRANCH].☆☆☆☆☆"
  bash /my-blog/bash/public.sh
fi

## 取消代理设置
git config --global --unset http.proxy
tail -f /dev/null
