---
title: Nginx 反向代理 TCP 端口
date: 2021-10-10 10:16:40
description: Nginx 反向代理 TCP 端口
categories: [Nginx篇]
tags: [Nginx]
---

<!-- more -->

```shell
stream {

    upstream rabbit {
    server 172.30.241.82:5672;
    }
    
    server{
    listen 45672;
    proxy_pass rabbit;
    }
}
```


stream 放到和 http 同一级

别忘了开启防火墙端口

```firewall-cmd --zone=public --add-port=45672/tcp --permanent```
```firewall-cmd --reload ```