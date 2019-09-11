---
title: 群晖系列 --- 添加私有仓库无法下载镜像问题的解决
date: 2019-09-09 12:45:26
description: 在群晖的 Docker 组件里添加了个人的私有仓库,发现却无法下载镜像....
categories: [群晖篇]
tags: [群晖,Docker]
---

<!-- more -->
### 背景
在群晖的 Docker 组件里添加了个人的私有仓库,发现却无法下载镜像....

### 分析
在 Docker 组件里添加新的仓库,并设置为使用仓库,发现在仓库里下载镜像总是失败,状态栏提示查看日志,可是在日志里总看不到东西

想了想,可能是新添加的 docker 私服是 http 的服务,而不是 https

### 方法
1. 于是我使用 GateOne 组件进入 shell 
2. 使用命令 docker pull xxx:xxx, 发现报错 `Get https://172.18.18.90:5000/v2/: http: server gave HTTP response to HTTPS client` , 果然是这个问题
3. 于是找到 Docker 组件的配置文件目录,在 `/var/packages/Docker/etc` 目录下,添加配置文件 daemon.json 

```json
    {
    "insecure-registries": ["domain:5000"]
    }
```

4. 重启 Docker 组件, 发现不起作用,在命令行下 pull 依然报错,可想配置文件错了
5. 转眼看到一个可疑的配置文件 `dockerd.json`, 里面已经有一些配置了,于是就把配置写到这个里面
6. 再重启,问题解决.可见群晖对于 docker 是做了一些改变的.