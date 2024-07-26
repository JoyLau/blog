---
title: Docker 配置容器 DNS 服务
date: 2024-07-26 17:53:40
description: Docker 配置容器 DNS 服务
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## 配置
```json
{
  "log-opts": {
    "max-size": "100m"
  },
  "data-root": "/data/docker-data",
  "dns": ["192.168.1.17","223.5.5.5"]
}
```

配置上面的 dns 配置，对所有的容器生效

我在本地用 docker 部署了一个 webmin 服务，其中 bind 可以用来做DNS 服务
启动docker 容器后发现，不能通过 192.168.1.17 来解析域名
解决办法是 webmin 的服务使用 host 网络即可

```yaml
version: "3"
services:
  dns-server:
    image: sameersbn/bind:9.16.1-20200524
    container_name: dns-server
    restart: always
    volumes:
      - ./data:/data
    network_mode: "host"
    #ports:
    #  - 53:53/udp
    #  - 10000:10000
    environment:
      - ROOT_PASSWORD=xxxx
      - WEBMIN_INIT_SSL_ENABLED=false
```

