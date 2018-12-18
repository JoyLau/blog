---
title: Docker 私服搭建记录
date: 2018-11-19 22:51:33
description: 国内的网络环境不好,在 docker build 的时候经常因为网络的问题失败,很是苦恼
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
1. docker pull registry
2. docker run -itd -v /data/registry:/var/lib/registry -p 5000:5000 --restart=always --privileged=true --name registry registry:latest
    参数说明
    -itd：在容器中打开一个伪终端进行交互操作，并在后台运行；
    -v：把宿主机的/data/registry目录绑定 到 容器/var/lib/registry目录(这个目录是registry容器中存放镜像文件的目录)，来实现数据的持久化；
    -p：映射端口；访问宿主机的5000端口就访问到registry容器的服务了；
    --restart=always：这是重启的策略，假如这个容器异常退出会自动重启容器；
    --privileged=true 在CentOS7中的安全模块selinux把权限禁掉了，参数给容器加特权，不加上传镜像会报权限错误OSError: [Errno 13] Permission denied: ‘/tmp/registry/repositories/liibrary’)或者（Received unexpected HTTP status: 500 Internal Server Error）错误
    --name registry：创建容器命名为registry，你可以随便命名；
    registry:latest：这个是刚才pull下来的镜像；

3. 测试是否成功: curl http://127.0.0.1:5000/v2/_catalog, 返回仓库的镜像列表
4. 在中央仓库下载一个镜像: docker pull openjdk
5. 更改这个镜像的标签: docker tag imageId domain:5000/openjdk 或者 docker tag imageName:tag domain:5000/openjdk
6. 上传镜像到私服: docker push domain:5000/openjdk


报错: Get https://172.18.18.90:5000/v2/: http: server gave HTTP response to HTTPS client

解决: 需要https的方法才能上传，我们可以修改下daemon.json
      vim /etc/docker/daemon.json 
      {
        "insecure-registries": [ "domain:5000"]
      }

### 无网络搭建
1. 在有网络的机器上 `docker pull registry`
2. `docker save registry > registry.tar` 保存到个 tar 包
3. 拷贝到服务器上, `docker load -i registry.tar` 导入镜像
4. `docker images` 查看镜像
5. 再继续上面的操作

### docker 开启 tcp 端口 
- `vim /usr/lib/systemd/system/docker.service `

修改

``` bash
    ExecStart=/usr/bin/dockerd-current -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock \
```

重启即可,之后 idea 可输入 tcp://ip:2375 连接

### 允许跨域请求

``` bash
    version: 0.1
    log:
      fields:
        service: registry
    storage:
      cache:
        blobdescriptor: inmemory
      filesystem:
        rootdirectory: /var/lib/registry
    http:
      addr: :5000
      headers:
        X-Content-Type-Options: [nosniff]
        Access-Control-Allow-Headers: ['Origin,Accept,Content-Type,Authorization']
        Access-Control-Allow-Origin: ['*']
        Access-Control-Allow-Methods: ['GET,POST,PUT,DELETE']
    health:
      storagedriver:
        enabled: true
        interval: 10s
        threshold: 3
```

head 添加

``` yml
    Access-Control-Allow-Headers: ['Origin,Accept,Content-Type,Authorization']
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['GET,POST,PUT,DELETE']
```

之后保存到本地,再挂载到容器的 /etc/docker/registry/config.yml 中

### Harbor 搭建 Docker 私服
上述方式搭建的 docker 私服,属于比较简单使用的方法,只能在命令行上操作,很不方便,比如不能直接删除镜像,无法添加用户,设置私有仓库
Harbor 是一个图形化的私服管理界面,安装使用更易于操作

> Harbor是一个用于存储和分发Docker镜像的企业级Registry服务器，通过添加一些企业必需的功能特性，例如安全、标识和管理等，扩展了开源Docker Distribution。作为一个企业级私有Registry服务器，Harbor提供了更好的性能和安全。提升用户使用Registry构建和运行环境传输镜像的效率。

1. 下载离线包: https://github.com/goharbor/harbor/releases
2. 解压
3. 更改配置文件 `docker-compose.yml` 私服的仓库端口我们默认设置为 5000,但是 docker-compose.yml 文件中并没有配置,我们需要添加一个 ports 配置

``` yml
      registry:
        networks:
          - harbor
        ports:
          - 5000:5000
```

4. Harbor 默认使用的是 80 端口,不想使用的话可切换其他端口, 配置在 docker-compose.yml 的最下方

``` yml
      proxy:
        image: goharbor/nginx-photon:v1.7.0
        ports:
          - 9339:80
          - 443:443
          - 4443:4443
```

此处需要注意的是,如果更改了其他端口,则需要在 `common/templates/registry/config.yml` 文件中更改一个配置 realm 加上端口,否则登录会出现错误

``` yml
    auth:
      token:
        issuer: harbor-token-issuer
        realm: $public_url:9339/service/token
        rootcertbundle: /etc/registry/root.crt
        service: harbor-registry
``` 

5. 修改配置文件 `harbor.cfg`

``` bash
    hostname = 34.0.7.183 ## 改为 IP 或者 域名,不要写错 localhost 或者 127.0.0.1
    ui_url_protocol = http ## http 方式
    harbor_admin_password = Hardor12345 ## admin 账号的默认登录密码
```

6. `./prepare ` 完成配置

7. `./install.sh ` 开始安装

8. 打开浏览器

9. 创建一个项目 `joylau` 注意这个名称很重要,名称对不上的话,会造成 image push 不成功,还有就是若果这个项目的是公开的话,则所有人都可以 pull ,但是 push 的话是需要登录的,登录的用户名和密码在该项目的成员下.默认的 admin 用户就可以

10. 登录,退出命令 `docker login 34.0.7.183:5000 ; docker logout 34.0.7.183:5000`

11. 之后的操作都是日常操作了