---
title: Docker常用命令备忘
date: 2017-3-22 12:33:48
description: 记下自己常用的Docker命令，以便快速查询和备忘
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### Docker

- 安装： `yum install docker`
- 卸载： `yum remove docker`
- 启动： `systemctl start docker`
- 开机自启： `systemctl enable docker`


### Dockerfile
``` bash
    FROM java:8
    MAINTAINER joylau
    ADD joyalu-0.0.1-SNAPSHOT.jar joylau.jar
    EXPOSE 8080
    ENTRYPOINT ["java","-jar","/joylau.jar"]
```


### 镜像
- 编译镜像: `docker build –t joylau/docker .`
- 查看镜像： `docker images`
- 删除镜像： `docker rmi name/id`


### 容器
- 运行: `docker run –d --name joylau –p 8080:8080 joylau/docker`
- 停止容器： `docker stop id/name`
- 查看运行中的容器 ：  `docker ps`
- 查看所有容器：  `docker ps -a`
- 删除容器：  `docker rm id/name`


## 2018-07-05 16:05:00 更新

拉取docker镜像

docker pull image_name
查看宿主机上的镜像，Docker镜像保存在/var/lib/docker目录下:

docker images

删除镜像

docker rmi  docker.io/tomcat:7.0.77-jre7   或者  docker rmi b39c68b7af30
查看当前有哪些容器正在运行

docker ps
查看所有容器

docker ps -a
启动、停止、重启容器命令：

docker start container_name/container_id
docker stop container_name/container_id
docker restart container_name/container_id
后台启动一个容器后，如果想进入到这个容器，可以使用attach命令：

docker attach container_name/container_id
删除容器的命令：

docker rm container_name/container_id
删除所有停止的容器：

docker rm $(docker ps -a -q)
查看当前系统Docker信息

docker info
从Docker hub上下载某个镜像:

docker pull centos:latest
docker pull centos:latest
查找Docker Hub上的nginx镜像

docker search nginx
执行docker pull centos会将Centos这个仓库下面的所有镜像下载到本地repository。

## 2018-07-09 14:02:25 更新
docker search xxx : 在docker仓库查找镜像
docker images | grep xxx : 在本地仓库查找镜像
