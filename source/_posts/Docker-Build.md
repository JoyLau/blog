---
title: Docker Build Image 问题记录
date: 2018-12-13 14:49:18
description: 这里记录下日常 docker build 遇到的问题,现在记录整理如下
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## 时区问题
时区的配置在 `/etc/localtime`

localtime 文件会指向 `/usr/share/zoneinfo/Asia/` 目录下的某个文件

我们只需要将其指向 ShangHai 即可

Dockerfile 可以这样配置

``` bash
    RUN rm -rf /etc/localtime && \
        ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

先删除,在创建一个软连接即可



