---
title: Nginx upstream 根据自定义 hash 规则进行路由
date: 2023-09-25 10:36:03
description: Nginx upstream 根据自定义 hash 规则进行路由
categories: [Nginx篇]
tags: [Nginx]
---

<!-- more -->

```shell
upstream MDM_WS {
    hash '$proxy_add_x_forwarded_for';
    server mdm:6611;
    server mdm-slave:6611;
}

upstream MDM_SERVER {
    hash '$proxy_add_x_forwarded_for';
    server mdm:6603;
    server mdm-slave:6608;
}

server {
    listen       80;
    underscores_in_headers on;

    location /mdmWs {
       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "upgrade";
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_set_header X-Forwarded-Host $host;
       proxy_buffering off;

       proxy_pass http://MDM_WS/mdmWs/;
    }

    location / {
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_set_header X-Forwarded-Host $host;
       proxy_buffering off;

       proxy_pass http://MDM_SERVER/;
    }


}
```