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
