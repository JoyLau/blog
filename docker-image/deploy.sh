#! /bin/bash
echo "Content-Type:text/html"
echo ""
cd /my-blog/blog/
git checkout -- _config.yml
git pull
sed -i "/^  repository:/c\ \ repository: $PUSH_GIT_REPO" _config.yml
sed -i "/^  branch:/c\ \ branch: $PUSH_BRANCH" _config.yml
cnpm install -d
hexo g -d --debug | tee /my-blog/logs/genrate.log