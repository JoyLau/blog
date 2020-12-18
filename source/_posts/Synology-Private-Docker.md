---
title: 群晖系列 --- 使用群晖搭建 Docker 私有仓库并管理
date: 2019-06-29 10:51:45
description: 之前写过基于 docker compose 使用 Harbor 搭建 Docker 私有仓库并管理,但是群晖里只有 docker 的管理,没有 docker compose 的直接支持
categories: [群晖篇]
tags: [群晖]
---

<!-- more -->
### 背景
docker 仓库存储大量的镜像,占用的空间很大,放到群晖上存储再合适不过了
之前写过基于 docker compose 使用 Harbor 搭建 Docker 私有仓库并管理,但是群晖里只有 docker 的管理,没有 docker compose 的直接支持
现在来个简单的仓库管理

### 方法
1. 安装 docker 套件
2. 下载 registry 和 joxit/docker-registry-ui 镜像
3. 分别启动这 2 个容器,注意配置

### registry 配置
1. 配置挂载目录
2. 配置环境变量,因为默认的 registry 镜像不支持跨域请求和没有开启删除镜像的功能,我曾尝试在镜像里修改配置文件,然后在导出镜像,但是失败了,新导出的镜像启动后无法提供服务
3. 环境配置如下

![Synology-Private-Docker](http://image.joylau.cn/blog/Synology-Private-Docker.png)

REGISTRY_STORAGE_DELETE_ENABLED:true  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers:['Origin,Accept,Content-Type,Authorization']  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods:['GET,POST,PUT,DELETE','HEAD']  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin:['*']  
REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers:['Docker-Content-Digest']  

### 后续配置
路由器开启端口映射即可


### 镜像的删除
首先要说的是,这里有个坑, 官方提供的删除镜像仓库中镜像的接口，仅仅是把 manifest 删除了，真正的镜像文件还存在！官方并没有提供删除镜像层的接口！这也就是说，当我们调用删除镜像的接口之后，仅仅是查看镜像的列表时看不到原镜像了，然而原有镜像仍然在磁盘中，占用着宝贵的文件存储空间

这里使用官方提供的 GC 工具来清除无用文件

### 删除方式 1
1. 在 web 界面上删除,或者调用 api 删除:

```text
    获取待删镜像的digest
    
    获取镜像digest的API为：
    
    GET /v2/<tag>/manifests/<version>

    例如: /v2/joy/blog.joylau.cn/manifests/1.0
    
    其中，name是仓库名，reference是标签，此时需要注意，调用时需要加上header内容：
    
    Accept： application/vnd.docker.distribution.manifest.v2+json
    
    其中Docker-Content-Digest的值就是镜像的digest
    
    3、调用官方的HTTP API V2删除镜像
    
    删除镜像的API为：
    
    DELETE /v2/<name>/manifests/<sha256>
    
    例如: /v2/joy/blog.joylau.cn/manifests/sha256:6c2daa1642b94dabdfaa32a9d3943cb92036c55117961fa9fcc4cc29348e5d39

    
    其中，name是仓库名称，reference是包含“sha256：”的digest。
```

2. 进入容器里调用GC清理镜像文件

```bash
    bin/registry garbage-collect /etc/docker/registry/config.yml
```

注意: gc不是事务操作，当gc过程中刚好有push操作时，则可能会误删数据，建议设置read-only模式之后再进行gc，然后再改回来

3. 重启 docker registry
注意，如果不重启会导致push相同镜像时产生layer already exists错误。


### 删除方式 2
使用第三方开源工具: https://github.com/burnettk/delete-docker-registry-image

该工具也提供了dry-run的方式，只输出待删除的信息不执行删除操作。在命令后加上——dry-run即可

跟gc方式一样，删除镜像之后要重启docker registry，不然还是会出现相同镜像push不成功的问题。

### docker-registry-ui 对于有认证的 docker 私服的配置 [2020-04-09 更新]
对于没有认证的 docker 私服,使用方式上面已经有配置了
对于有认证的 docker 私服,却有点变化
需要改变:

REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods:['GET,POST,PUT,DELETE','HEAD']  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin:['<your docker-registry-ui url>']  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials: [true]


另外,对于有认证的 docker 私服,删除镜像还有有问题的:
具体情况见: https://github.com/Joxit/docker-registry-ui/issues/104

简单来说是 docker 私服的锅,并不是 Joxit/docker-registry-ui 的问题,因为在浏览器再监测是否允许跨域请求发出的 options 请求被返回了 401 状态,导致后续请求无法发出

而实际上应该返回 20x 的请求

作者给出方法是: 将 docker 私服和 docker-registry-ui 放到同一个域下

那我这边还是以 群晖的 docker 来配置 nginx 来实现这样的功能

nginx 配置如下:

1. /etc/nginx/nginx.conf, 这个没有变化,我们将其外置,方便日后修改:

```editorconfig
    user  nginx;
    worker_processes  1;
    
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;
    
    
    events {
        worker_connections  1024;
    }
    
    
    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;
    
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';
    
        access_log  /var/log/nginx/access.log  main;
    
        sendfile        on;
        #tcp_nopush     on;
    
        keepalive_timeout  65;
    
        #gzip  on;
    
        include /etc/nginx/conf.d/*.conf;
    }
```

2. /etc/nginx/conf.d/default.conf: 这个文件我们添加反向代理,使得 docker 私服和 docker-registry-ui 在同一个域下

```editorconfig
    server {
        listen       80;
        server_name  localhost;
    
        #charset koi8-r;
        #access_log  /var/log/nginx/host.access.log  main;
    
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
    
        #location / {
        #    #rewrite ^/b/(.*)$ /$1 break;
        #    proxy_set_header Host $host;
        #    proxy_set_header X-Real-IP $remote_addr;
        #    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #    proxy_pass http://nas.joylau.cn:5007/; # 转发地址,注意要有/
        #}
        
        location /v2 {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://xxxx:xxx/v2; # 转发地址
        }
    
        location /ui {
            rewrite ^/b/(.*)$ /$1 break; # 去除本地接口/ui前缀, 否则会出现404
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://xxxx:xxx/; # 转发地址,注意要有/
        }
    
        #error_page  404              /404.html;
    
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    
        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}
    
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}
    
        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }
```

访问方式:
1. docker-registry-ui 的访问直接使用 nginx 的地址, 后面加上 `/ui/`, 这样就会代理到之前的 docker-registry-ui 的服务
2. docker registry 的地址直接填 nginx 提供服务的`主机 + 端口号`即可, 后面不需要加其他东西

这样方式在 docker-registry-ui 连接 docker 私服时会弹框输入用户名密码, 也能完美解决删除镜像的问题


### Docker 私服配置 SSL 证书
1. 去证书申请网站上下载证书, 我的是阿里云的, 下载下来的压缩包里有 2 个文件 .key 和 .pem
2. 将这 2 个文件上传到 NAS 上, 配置 registry 挂载这 2 个文件, 并配置如下 2 个环境变量, 重启 registry 容器即可

```bash
      -e REGISTRY_HTTP_TLS_CERTIFICATE=/server.crt
      -e REGISTRY_HTTP_TLS_KEY=/server.key
```

REGISTRY_HTTP_TLS_CERTIFICATE 这个变量指定的文件可以在挂载的时候将 .pem 直接更名为 .crt 文件