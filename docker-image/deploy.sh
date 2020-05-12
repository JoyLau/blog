#! /bin/bash
echo "Content-Type: text/html;charset=UTF-8"
echo "Content-Language: zh-CN"
echo ""
cd /my-blog/blog/
git checkout -- _config.yml
git pull | tee /my-blog/logs/genrate.log
sed -i "/^  repository:/c\ \ repository: $PUSH_GIT_REPO" _config.yml
sed -i "/^  branch:/c\ \ branch: $PUSH_BRANCH" _config.yml

# -v: 啰嗦模式, 打印所有信息, 否则的话,以后台运行,为了更快的响应请求并返回
if [[ $1 == '-v' ]]; then
  hexo g -d --debug | tee /my-blog/logs/genrate.log
  # 写入 git 用户配置, 防止 fastcgi push 时出错
  echo -e "[user]\n\t\tname = $GIT_USER_NAME\n\t\temail = $GIT_USER_EMAIL">>/my-blog/blog/.deploy_git/.git/config
else
  nohup hexo g -d --debug >>/my-blog/logs/genrate.log 2>&1 &
fi

echo "<p>Please view the <a href='logs.sh' target='_blank'>Logs</a></p>"
