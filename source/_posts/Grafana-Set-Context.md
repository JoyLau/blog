---
title: Grafana 设置二级目录及配置 Nginx 代理
date: 2021-02-15 11:00:01
description: Grafana 设置二级目录及配置 Nginx 代理
categories: [Grafana篇]
tags: [Grafana]
---

<!-- more -->

## 步骤
设置环境变量：

``` yaml
    env:
    - name: GF_SERVER_ROOT_URL
      value: "%(protocol)s://%(domain)s:%(http_port)s/grafana"
    - name: GF_SERVER_SERVE_FROM_SUB_PATH
  value: "true"
```



此时 NGINX 进行反向代理的配置：

```nginx
    location /grafana/ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://10.55.3.160:31120/;
    }
```