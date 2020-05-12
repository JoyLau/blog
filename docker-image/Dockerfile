FROM node:latest
MAINTAINER joylau 2587038142.liu@gmail.com
LABEL Descripttion="This image is JoyLau's Bolg"
# GIT 信息配置
ENV GIT_USER_EMAIL="2587038142.liu@gmail.com"
ENV GIT_USER_NAME="JoyLau"

# 需要 pull 下来进行编译的 git 仓库
ENV PULL_GIT_REPO="https://github.com/JoyLau/blog.git"
# 同上,定义分支
ENV PULL_BRANCH master

# 编译完成后需要 push 的 git 仓库, 需要将 name:password 替换成实际的 github 的用户名和密码
ENV PUSH_GIT_REPO="https://name:password@github.com/JoyLau/blog-public.git"
# 同上, 去掉了用户名密码
ENV PUBLIC_GIT_REPO="https://github.com/JoyLau/blog-public.git"
# 同上,定义分支
ENV PUSH_BRANCH master

# 需要进行的操作, deploy: pull [PULL_GIT_REPO] 进行编译,并发布部署; public: 只 pull 下来编译后的仓库 [PUBLIC_GIT_REPO], 以供直接访问
ENV MODE='deploy,public'

# 定义 git 代理设置, 格式 http://name:pass@host:port, 防止网络环境不好,拉取代码仓库失败
ENV PROXY=''

EXPOSE 80 8081
ADD sources.list /etc/apt/sources.list
RUN apt-get update &&\
    apt-get install -y gosu nginx git fcgiwrap &&\
    npm install hexo -g &&\
    npm install -g cnpm --registry=https://registry.npm.taobao.org
COPY nginx.default.conf /etc/nginx/sites-available/default
RUN mkdir -p /my-blog/bash /my-blog/logs
COPY *.sh /my-blog/bash/
RUN chown -R www-data:www-data /my-blog &&\
    chmod -R 777 /var/www &&\
    chmod +x /my-blog/bash/*.sh
ENTRYPOINT ["/my-blog/bash/docker-entrypoint.sh"]
CMD ["/my-blog/bash/init.sh"]
