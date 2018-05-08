---
title: Logstash 实时收集 Nginx 日志
date: 2018-5-8 08:38:25
description: "吃个晚饭回来继续写上一篇 Logstash 实时收集 Nginx 日志的方法"
categories: [大数据篇]
tags: [Logstash,Nginx]
---

<!-- more -->

## 说明
logstash 需要和 nginx 部署到一台机器
需要修改 nginx 的日志格式

## nginx.config
更改日志记录的格式

```` bash
    log_format  json '{
                          "timestamp":"$time_iso8601",
                          "remote_addr":"$remote_addr",
                          "remote_user":"$remote_user", 
                          "body_bytes_sent":"$body_bytes_sent",
                          "request_time":"$request_time",
                          "status":"$status",
                          "request": "$request",
                          "host":"$host",
                          "request_method": "$request_method",
                          "http_referrer": "$http_referer",
                          "http_x_forwarded_for": "$http_x_forwarded_for", 
                          "http_user_agent": "$http_user_agent",
                          "url":"$uri"
                          }'
    
    access_log  /var/log/nginx/access.log  json;

````



## log-file.config
input 里添加 file 类型

``` bash
    input {
        file {
            path => "/var/log/nginx/access.log"
            codec => "json"
            start_position => "beginning"
            type => "server_nginx"
            tags => ["nginx"]
        }
    }
    
    output {
            elasticsearch {
                    hosts => ["http://192.168.10.232:9211"]
                    index => "logstash_%{type}_%{+YYYY-MM}"
            }
         }

```
