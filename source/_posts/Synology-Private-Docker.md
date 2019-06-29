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
2, 下载 registry 和 joxit/docker-registry-ui 镜像
3. 分别启动这 2 个容器,注意配置

### registry 配置
1. 配置挂载目录
2. 配置环境变量,因为默认的 registry 镜像不支持跨域请求和没有开启删除镜像的功能,我曾尝试在镜像里修改配置文件,然后在导出镜像,但是失败了,新导出的镜像启动后无法提供服务
3. 环境配置如下

![Synology-Private-Docker](http://image.joylau.cn/blog/Synology-Private-Docker.png)

REGISTRY_STORAGE_DELETE_ENABLED:true  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers:['Origin,Accept,Content-Type,Authorization']  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods:['GET,POST,PUT,DELETE']  
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin:['*']  
REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers:['Docker-Content-Digest']  

### 后续配置
路由器开启端口映射即可