---
title: Docker 日志信息
date: 2019-11-19 11:43:08
description: docker 容器启动, 通过 docker logs -f container 可以实时查看日志,但是控制台输出的日志太多,会怎么样,容器里控制台输出的日志在宿主机什么位置?
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## 背景
docker 容器启动, 通过 docker logs -f container 可以实时查看日志

但是控制台输出的日志太多,会怎么样,容器里控制台输出的日志在宿主机什么位置?

有时容器输出太多,运行时间长了后,会把磁盘撑满...

## 解释
docker 里容器的日志都属于标准输出（stdout）
每个 container 都是一个特殊的进程，由 docker daemon 创建并启动,docker daemon 来守护和管理

docker daemon 有一个默认的日志驱动程序，默认为json-file
json-file 会把所有容器的标准输出和标准错误以json格式写入文件中，这个文件每行记录一个标准输出或标准错误并用时间戳注释


## 修改配置
1. vim /etc/docker/daemon.json

2. 增加一条：{"log-driver": "none"} （也可以添加{"log-opts": {"max-size": "10m" }} 来控制log文件的大小）

3. 重新加载配置文件并重启docker服务: systemctl daemon-reload

## 查看日志位置
1. docker inspect container_id | grep log
2. 进入上述目录
3. du -sh *




