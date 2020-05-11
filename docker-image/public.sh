#! /bin/bash
echo "Content-Type:text/html"
echo ""
cd /my-blog/blog/
git clone -v --progress --depth=1 -b $PUSH_BRANCH $PUBLIC_GIT_REPO public && echo "clone repo success!!!" || exit 1