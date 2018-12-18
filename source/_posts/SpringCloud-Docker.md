---
title: SpringCloud --- Docker 部署问题记录
date: 2018-12-18 08:45:35
description: 该篇文章记录使用 Docker 部署 SpringCloud 遇到的问题
categories: [SpringCloud篇]
tags: [SpringCloud,Docker]
---

<!-- more -->

### Docker 容器中 IP 的配置
将 spring cloud 项目部署到 docker 容器中后,虽然可以配置容器的端口映射到宿主机的端口
但是在 eureka 界面显示的instance id 是一串随机的字符串,类似于 d97d725bf6ae 这样的
但是,事实上,我们想让他显示出 IP ,这样我们可以直接点击而打开 info 端点信息

修改 3 处配置项:


``` yml
    eureka:
      client:
        service-url:
          defaultZone: http://34.0.7.183:9368/eureka/
      instance:
        prefer-ip-address: true
        instance-id: ${eureka.instance.ip-address}:${server.port}
        ip-address: 34.0.7.183
```

1. `eureka.instance.prefer-ip-address` 配置为 true , 表示 instance 使用 ip 配置
2. `eureka.instance.prefer-ip-address` 配置当前 instance 的物理 IP
3. `eureka.instance.prefer-instance-id` 界面上的 instance-id 显示为 ip + 端口