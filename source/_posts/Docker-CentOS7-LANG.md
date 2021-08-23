---
title: Docker 解决 CentOS 7 镜像中中文乱码的问题
date: 2021-08-23 11:53:11
description: 解决 CentOS 7 镜像中中文乱码的问题
categories: [Docker篇]
tags: [Docker]
---
<!-- more -->
### 解决

Dockerfile

```dockerfile
    FROM centos:7
    # 解决镜像中文乱码的问题
    RUN yum install -y glibc-common kde-l10n-Chinese
    RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
    ENV LC_ALL zh_CN.UTF-8
```



