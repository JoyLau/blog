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
REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods:['GET,POST,PUT,DELETE']  
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