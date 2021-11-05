---
title: Nginx 配置非 80 和 443 端口设置HTTP请求自动跳转HTTPS
date: 2021-10-20 10:16:40
description: Nginx 配置非 80 和 443 端口设置HTTP请求自动跳转HTTPS
categories: [Nginx篇]
tags: [Nginx]
---

<!-- more -->

配置 https:

```shell
listen       80 ssl;
ssl_certificate /etc/nginx/conf.d/epark.ahhtk.com.pem;
ssl_certificate_key /etc/nginx/conf.d/epark.ahhtk.com.key;
ssl_session_timeout 5m;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
#表示使用的加密套件的类型。
ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #表示使用的TLS协议的类型。
ssl_prefer_server_ciphers on;
```


正常情况下使用 80 和 443 端口实现 http 自动跳转 https 的话配置：

```shell
server {
    listen 80;
    server_name yourdomain.com; #需要将yourdomain.com替换成证书绑定的域名。
    rewrite ^(.*)$ https://$host$1; #将所有HTTP请求通过rewrite指令重定向到HTTPS。
    location / {
      index index.html index.htm;
    }
}
```

如果不是正常的端口的话，注释掉上面的 rewrite 配置，新增如下配置即可

```error_page 497 301 https://$http_host$request_uri;```