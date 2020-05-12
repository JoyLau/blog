#! /bin/bash
echo "Content-Type: text/html;charset=UTF-8"
echo "Content-Language: zh-CN"
echo ""
cd /my-blog/
if [ ! -d "blog" ]; then
  mkdir /my-blog/blog
fi
cd /my-blog/blog/

if [ ! -d "public" ]; then
  git clone -v --progress --depth=1 -b $PUSH_BRANCH $PUBLIC_GIT_REPO public && echo "clone repo success!!!" || exit 1
else
  cd /my-blog/blog/public
  git pull | tee /my-blog/logs/genrate.log
fi