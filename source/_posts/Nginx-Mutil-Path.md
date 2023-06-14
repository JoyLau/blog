---
title: Nginx 反向代理配置多个前缀匹配
date: 2023-06-15 09:34:11
description: Nginx 反向代理配置多个前缀匹配
categories: [Nginx篇]
tags: [Nginx]
---

<!-- more -->
配置场景:
有时我们有多个前缀需要反向代理到同一个后端服务，
比如 /s1, /s2, /s3-xxx, 都代理到同一个后端服务
最普通的写法可以写多个 location 来匹配， 这里介绍使用一个 location 完成匹配


```shell
    location ~* ^/(s1|s2|s3-*)/ {
       proxy_pass http://GATEWAY;

       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "upgrade";
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_set_header X-Forwarded-Host $host;
    }
```

上面还配置了支持升级http协议支持了https
