---
title: Docker 使用阿里云个人专属加速器
date: 2018-07-12 09:48:38
description: 原来阿里云给每个账户都有分配专属的加速器地址
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
0. 原来阿里云给每个账户都有分配专属的加速器地址
1. 登录阿里云控制台
2. 进入容器镜像服务，点击最下方的镜像加速器，会出现个人的专属加速器地址，我的是： https://0ppztvl0.mirror.aliyuncs.com
3. Docker客户端版本大于1.10.0的用户，创建 `/etc/docker/daemon.json`
    {
      "registry-mirrors": ["https://0ppztvl0.mirror.aliyuncs.com"]
    }
    
    sudo systemctl daemon-reload
    sudo systemctl restart docker