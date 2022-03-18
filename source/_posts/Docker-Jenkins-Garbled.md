---
title: Docker 搭建 Jenkins 构建流水线控制台输出乱码
date: 2021-12-18 14:54:55
description: Docker 搭建 Jenkins 构建流水线控制台输出乱码
categories: [Docker篇]
tags: [Docker, Jenkins]
---

<!-- more -->

按照晚上的教程，配置了
JAVA_TOOL_OPTIONS="-Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8" 
和 LANG=C.UTF-8 

这些都没有解决问题

### 问题解决

主要问题是主节点配置连接从节点的账号 jenkins 没有初始化环境变量
查看从节点的系统信息，可以看到 file.encoding 是 ASNI 编码
解决办法就是新建一个用户使用 -d 指定 home 目录，

```useradd -d /home/jenkins jenkins```

目的是为了生成 .bashrc  .bash_logout .bash_profile 三个文件，将这 3 个文件拷贝到 Jenkins 的home 目录下并授权， 就解决了
再去看从节点的 file.encoding 已经变成 UTF-8 了

