---
title: Nacos --- 解决 Nacos 单机 MySQL 版重启服务器后无法提供服务的问题
date: 2022-05-05 10:20:55
description: 有时 Nacos 单机 MySQL 版重启服务器后无法提供服务， 是因为重启时均启动 nacos 服务和 MySQL 服务，而MySQL 服务启动的较慢， nacos 在启动的时候还连接不上数据库导致 Nacos 服务无法正常提供服务
categories: [Nacos篇]
tags: [Nacos]
---

<!-- more -->
## 背景
有时 Nacos 单机 MySQL 版重启服务器后无法提供服务， 是因为重启时均启动 nacos 服务和 MySQL 服务，而MySQL 服务启动的较慢， nacos 在启动的时候还连接不上数据库导致 Nacos 服务无法正常提供服务  
这里我的解决方式是使用 Nacos 单机 Derby 版

## 部署

docker-compose.yml 文件内容如下：

```yaml
    version: "2"
    services:
      nacos:
        image: nacos/nacos-server:v2.1.0
        container_name: nacos
        restart: always
        environment:
          - PREFER_HOST_MODE=ip
          - MODE=standalone
          - NACOS_AUTH_ENABLE=true
        volumes:
          - ./standalone-logs/:/home/nacos/logs
          - ./data:/home/nacos/data
        ports:
          - "8848:8848"
```

在 当前目录下新建文件夹 `data` 和 `standalone-logs` 启动服务即可