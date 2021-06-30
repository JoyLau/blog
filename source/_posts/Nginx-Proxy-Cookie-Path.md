---
title: Nginx 使用 proxy_cookie_path 解决反向代理 cookie 丢失导致无法登录的问题
date: 2021-06-30 17:05:55
description: Nginx 使用 proxy_cookie_path 解决反向代理 cookie 丢失导致无法登录的问题
categories: [Nginx篇]
tags: [Nginx]
---

<!-- more -->

## proxy_cookie_path 语法
proxy_cookie_path source target;
source 源路径
target 目标路径

## 使用原因
cookie 的 path 与地址栏上的 path 不一致
浏览器就不会接受这个 cookie，无法传入 JSESSIONID 的 cookie
导致登录验证失败

## 使用场景
当 nginx 配置的反向代理的路径和源地址路径不一致时使用

## 使用 Demo

```nginx
    # elastic-job 代理配置
    location /etc-job/api/ {
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_pass http://10.55.3.139:8088/api/;
       proxy_cookie_path / /etc-job/api/;
       proxy_set_header   Cookie $http_cookie;
    }
```