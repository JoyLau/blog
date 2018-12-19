---
title: Docker exec failed docker 无法进入容器问题解决
date: 2018-12-19 20:11:00
description: docker 进入容器失败,报错如下
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### 无法进入容器
docker exec -it name /bin/sh 失败,
查看容器 inspect 报错信息如下:

``` bash 
    pc error: code = 2 desc = oci runtime error: exec failed: 
    container_linux.go:247: starting container process caused "process_linux.go:110: 
    decoding init error from pipe caused \"read parent: connection reset by peer\""
```

### 问题分析
1. docker 版本为: Docker version 1.13.1, build 07f3374/1.13.1
2. centos 版本为: CentOS Linux release 7.3.1611 (Core) 
3. 错误原因: 似乎是 docker RPM 软件包的更新时引入的错误。一个临时的解决方法是将所有docker软件包降级到以前的版本（1.13.1-75似乎可以）

### 降级

``` shell
    yum downgrade docker docker-client docker-common
```





