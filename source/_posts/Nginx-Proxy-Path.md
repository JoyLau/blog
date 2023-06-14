---
title: Nginx 反向代理配置二级路径前缀
date: 2023-06-14 09:34:11
description: Nginx 反向代理配置二级路径前缀
categories: [Nginx篇]
tags: [Nginx]
---

<!-- more -->
使用场景: 前端访问的路径为 http://xxx:xx:/p1/p2/p3?p=xx

代理到后端的地址也是: http://xxx:xx:/p1/p2/p3?p=xx
现在想代理到后端的地址加一个前缀，变成 http://xxx:xx:/p0/p1/p2/p3?p=xx


```shell
    location /p1 {
       proxy_pass http://xxx:xx/p0/$request_uri;
    }
```
