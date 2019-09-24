---
title: Docker --- Maridb 容器启动时初始化数据库
date: 2019-09-23 17:43:01
description: Maridb 容器启动时初始化数据库问题的记录
categories: [Docker篇]
tags: [docker,mariaDB]
---

<!-- more -->
### 容器启动时初始化数据的方法
1. 编写好脚本,支持 .sql;.sh;.sql.gz
2. 容器启动时, 将脚本挂载到容器的 `/docker-entrypoint-initdb.d` 目录下即可

可就是这么简单的操作,我却没有成功...

### 注意
该方法只在初始化数据库的时候起作用,意思是,当你想把 mariadb 的数据目录 `/var/lib/mysql` 挂载到本地盘上,那么 该目下有文件时,放置的脚本将不会执行