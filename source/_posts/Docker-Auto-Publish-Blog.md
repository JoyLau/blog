---
title: 真·Docker 自动部署个人博客
date: 2020-03-18 16:41:53
description: Docker 自动部署个人博客
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->

### 何为 `真`
以前我都是服务器上执行定时任务,在凌晨的时候 pull 博客仓库在 hexo 编译, 在上传到 github 静态资源库, 在 pull 静态资源库到 nginx 目录下,这样实现个人博客的发布

真: 放弃定时任务, 采用 github 的钩子, 在博客仓库有 push 行为时,立马执行上述操作, 以前直接在服务器上写的脚本来执行,这次决定将这些操作打包成一个 docker 镜像, 随时随地可部署

避免了部署还需要配置定时任务和写一批脚本的问题.

### 环境准备
1. 以 Ubuntu 18.04 为基础镜像,进行镜像的制作
2. docker run -it -name blog-auto-publish ubuntu:18.04 /bin/bash
3. apt update
4. apt install git
5. apt install vim
6. rm -rf /etc/apt/sources.list
7. vim /etc/apt/sources.list

```shell script
    deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
    
    deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
    
    deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
    
    deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
    
    deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

```

8. apt update
9. apt install curl
10. curl -sL https://deb.nodesource.com/setup_13.x | bash 
11. apt-get install -y nodejs
12. npm install hexo -g
13. apt install nginx
14. apt install fcgiwrap


### 新建目录
mkdir /my-blog
mkdir -p /my-blog/bash
mkdir -p /my-blog/logs

### 克隆仓库
git clone https://github.com/JoyLau/blog.git

cd blog

npm install

### 建立命令
vim /my-blog/bash/init.sh

vim init.sh

```bash
    #!/usr/bin/env bash
    chown -R www-data:www-data /my-blog/* && service fcgiwrap start && service nginx start && tail -f -n 500 /my-blog/logs/publish.log

```

vim /my-blog/bash/pull-deploy.sh

```bash
    #! /usr/bin/env bash
    cd /my-blog/blog && \
    ## git checkout -- _config.yml && \
    git pull && \
    echo `pwd` && \
    ## update config
    ## sed -i "s/https:\/\/name:password@github.com\/JoyLau\/blog-public.git/https:\/\/$GITHUB_REPO_USERNAME:$GITHUB_REPO_PASSWORD@github.com\/$GITHUB_REPO_USERNAME\/$GITHUB_REPO_NAME.git/g" _config.yml && \
    ## hexo clean && \
    hexo g
    ## hexo d

```

vim /my-blog/bash/publish.sh
 
```bash
    #!/bin/bash
    echo "Content-Type:text/html"
    echo ""
    echo "ok"
    /my-blog/bash/pull-deploy.sh>/my-blog/logs/publish.log

```

注意: 前 2 行是必须的.这样发出请求会有返回

### 配置 nginx
vim /etc/nginx/sites-available/default 

```nginx
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

    }

    server {
            listen 8080 default_server;
            listen [::]:8080 default_server;
    
            root /my-blog/bash;
    
            server_name _;
    
            location ~ ^/.*\.sh  {
              gzip off;
              fastcgi_pass  unix:/var/run/fcgiwrap.socket;
              include fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            }
    }


```

nginx -t 检查错误

### 注意
1. fcgiwrap 不能以 root 组或者 root 用户运行, 这点在配置文件 /etc/init.d/fcgiwrap 可以配置,默认为 www-data, 因此 nginx 的用户也设置为 www-data,同时设置 /my-blog 目录下所属者为 www-data


### Dockerfile
```text
    FROM nas.joylau.cn:5007/joy/blog.joylau.cn:1.0
    
    LABEL maintainer="blog.joylau.cn"
    
    ENV GITHUB_REPO_USERNAME ""
    ENV GITHUB_REPO_PASSWORD ""
    ENV GITHUB_REPO_NAME ""
    ENV REPO_INFO ""
    
    EXPOSE 80
    
    EXPOSE 8080
    
    CMD ["sh", "/my-blog/bash/init.sh"]
```

打包镜像:
docker build -t nas.joylau.cn:5007/joy/blog.joylau.cn:1.0 .

打包后镜像大小为: 294 MB

### 使用
docker run -p 8081:80 -p 8082:8080 -d --name blog.joylau.cn nas.joylau.cn:5007/joy/blog.joylau.cn:1.0


### 备注
1. 80 端口提供的服务为 blog 页面
2. 8080 端口提供的服务为执行 shell 命令
3. 提供 webhook 为 http://host:port/publish.sh ,通过请求这个请求来更新博客
4. 查看日志文件有 /my-blog/logs/publish.log 和 nginx 的日志文件 /var/log/nginx/error.log

### 后续优化备忘
1. 删除原来的 /var/log/nginx/error.log 日志里的错误信息，现有的错误信息是是测试使用产生的
2. 在镜像里就执行一遍 chown -R www-data:www-data /my-blog/* , 否则的话容器刚启动的时候会很慢， 可以不执行 hexo g ,使用 hexo g --watch 实时监听文件变化，也不需要 nginx 了，直接使用 hexo-server ,开启 --debug 参数打印详细日志信息 
3. 考虑将 publish.sh 的最后一行命令不等待执行完就返回，现在的情况是部署到配置较低的机器上执行很慢，会导致请求超时，虽然不影响执行结果
4. 配置好容器内的时区，使得日志的时间戳更明显


### 优化更新记录 [2020-04-01]
1. 设置时区:

```bash
    apt-get install tzdata
    然后依次选择 6 , 70 即可

    使用 dpkg-reconfigure tzdata 来重写选择
```

2. 清空 nginx 日志文件

```bash
    echo "" > /var/log/nginx/error.log 
    echo "" > /var/log/nginx/access.log 
```

3. webhooks 不等待执行完就返回
vim /my-blog/bash/publish.sh

```bash
    #!/bin/bash
    echo "Content-Type:text/html"
    echo ""
    echo "ok"
    /my-blog/bash/pull-deploy.sh>/my-blog/logs/publish.log 2>&1 &
```

4. 实时监听文件变化
vim /my-bog/bash/init.sh

```bash
    #!/usr/bin/env bash
    service fcgiwrap start
    service nginx start
    cd /my-blog/blog/ && nohup hexo g --watch >/my-blog/logs/hexo-generate.log 2>&1 &
    tail -f -n 500 /my-blog/logs/publish.log /my-blog/logs/hexo-generate.log /var/log/nginx/error.log /var/log/nginx/access.log 
```

5. 不使用 dockerfile 来构建,直接使用 docker commit

```bash
    docker commit -c 'CMD ["sh", "/my-blog/bash/init.sh"]' -c "EXPOSE 80" -c "EXPOSE 8080" -a "JoyLau" -m "JoyLau's Blog Docker Image"  blog nas.joylau.cn:5007/joy/blog.joylau.cn:2.1
```

### 优化更新记录 [2020-04-02]
更新脚本:

1. init.sh

```bash
    #!/usr/bin/env bash
    echo "Hello! log file in /my-blog/logs/publish.log"
    service fcgiwrap start
    service nginx start
    su - www-data -c "cd /my-blog/blog/ && git pull"
    cd /my-blog/blog/
    hexo g --watch | tee -a /my-blog/logs/publish.log

```

2. publish.sh

```bash
    #!/bin/bash
    echo "Content-Type:text/html"
    echo ""
    echo "ok\r\n"
    /my-blog/bash/pull-deploy.sh | tee -a /my-blog/logs/publish.log
```

3. pull-deploy.sh

```bash
    #! /usr/bin/env bash
    echo "Prepare to update Blog Posts....."
    cd /my-blog/blog/
    git pull

```

### 优化更新记录 [2020-04-07]
新增 republish.sh

```bash
    #!/usr/bin/env bash
    echo "prepare republish......"
    cd /my-blog/blog/
    hexo clean && hexo g
```

修改 init.sh

```bash
    #!/usr/bin/env bash
    echo "Hello! log file in /my-blog/logs/publish.log"
    service fcgiwrap start
    service nginx start
    su - www-data -c "cd /my-blog/blog/ && git pull && hexo g --watch | tee -a /my-blog/logs/publish.log"
```

### 使用 Dockerfile 构建 [2020-04-21 更新]
在容器里各种操作是在是太黑箱了,日后极难维护,这里我编写 Dockerfile 来构建镜像

#### Dockerfile

```dockerfile
    FROM node:latest
    MAINTAINER joylau 2587038142.liu@gmail.com
    LABEL Descripttion="This image is JoyLau's Bolg"
    ENV GIT_REPO="https://github.com/JoyLau/blog.git"
    ENV BRANCH master
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

```

#### docker-entrypoint.sh

```bash
    #!/bin/bash
    set -e
    if [ "$1" = '/my-blog/bash/init.sh' -a "$(id -u)" = '0' ]; then
        service nginx start
        service fcgiwrap start
        echo "☆☆☆☆☆ base service has started. ☆☆☆☆☆"
        exec gosu www-data "$0" "$@"
    fi
    exec "$@"
```

#### init.sh

````bash
    #! /bin/bash
    cd /my-blog
    echo "☆☆☆☆☆ your git repo is [$GIT_REPO] ; branch is [$BRANCH]. ☆☆☆☆☆"
    git clone -b $BRANCH --progress $GIT_REPO blog
    cd blog
    cnpm install -d
    hexo g --watch --debug | tee -a /my-blog/logs/genrate.log
````

#### nginx.default.conf

```config
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
    
        index index.html index.htm index.nginx-debian.html;
    
        server_name _;
    
        root /my-blog/blog/public;
    
        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }
    
    }
    
    server {
            listen 8080 default_server;
            listen [::]:8080 default_server;
    
            root /my-blog/bash;
    
            server_name _;
    
            location ~ ^/.*\.sh  {
              gzip off;
              fastcgi_pass  unix:/var/run/fcgiwrap.socket;
              include fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            }
    }
```

#### publish.sh

```bash
    #!/bin/bash
    echo "Content-Type:text/html"
    echo ""
    echo "<h1>ok</h1>"
    echo "<h3>Prepare to update Blog Posts.....</h3>"
    cd /my-blog/blog/
    git pull
```

#### republish.sh

```bash
    #!/bin/bash
    echo "Content-Type:text/html"
    echo ""
    echo "<h1>ok</h1>"
    echo "<h3>republish blog.....</h3>"
    cd /my-blog/blog
    hexo g --force
```

#### sources.list

```text
    deb http://mirrors.163.com/debian/ stretch main non-free contrib
    deb http://mirrors.163.com/debian/ stretch-updates main non-free contrib
    deb http://mirrors.163.com/debian/ stretch-backports main non-free contrib
    deb-src http://mirrors.163.com/debian/ stretch main non-free contrib
    deb-src http://mirrors.163.com/debian/ stretch-updates main non-free contrib
    deb-src http://mirrors.163.com/debian/ stretch-backports main non-free contrib
    deb http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib
    deb-src http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib

```

#### 启动

```bash
    docker run -d --restart always --name blog -p 8001:80 -p 8002:8080 nas.joylau.cn:5007/joy/blog.joylau.cn:3.0
```