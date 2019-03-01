---
title: Docker-Swarm 集群搭建
date: 2019-02-18 11:36:04
description: 记录下 docker swarm 集群搭建的过程
categories: [Docker篇]
tags: [Docker,Docker Swarm]
---

<!-- more -->
### 环境
1. docker 18.09

### 说明
1. 本篇文章中的搭建过程有多台物理机,如果说是自己测试使用的话,或者只有一台机器,可以使用 docker-machine 来创建多个 docker 主机
2. 比如创建一个主机名为 work 的 docker 主机 : `docker-machine create -d virtualbox worker`
3. 之后进入刚才创建的主机 : `docker-machine ssh worker`
4. 然后就当成是一台独立机器来执行以下的操作

### 步骤
1. 初始化 swarm 集群 : `docker swarm init --advertise-addr 34.0.7.183`
    1. 机器有多个网卡的指定 IP 地址 --advertise-addr
    2. 默认创建的是管理节点
2. 加入刚才创建 swarm 集群

``` shell
    docker swarm join --token SWMTKN-1-1o1yfsquxasw7c7ah4t7lmd4i89i62u74tutzhtcbgb7wx6csc-1hf4tjv9oz9vpo937955mi0z2 34.0.7.183:2377
```

如果说忘了集群管理节点的 token, 可以使用 `docker swarm join-token work/manage` 来查看加入该集群的命令

3. 查看集群节点: `docker node list`


### 服务部署

1. 单服务部署 `docker service create --name nginx -p 80:80 --replaces 4 containAddress`
    上述命令部署了4个 nginx 服务,如果集群有2台主机的话,会在每台主机上部署 2 个服务

2. 多服务部署, 使用 yml 配置文件,具体语法参看 https://docs.docker.com/compose/compose-file/

### 命令

#### docker swarm 
docker swarm init	初始化集群
docker swarm join-token worker	查看工作节点的 token
docker swarm join-token manager	查看管理节点的 token
docker swarm join  加入集群中

#### docker stack
docker stack deploy	部署新的服务或更新现有服务
docker stack ls	列出现有服务
docker stack ps	列出服务中的任务
docker stack rm	删除服务
docker stack services	列出服务中的具体项
docker stack down	移除某个服务（不会删除数据）

#### docker node
docker node ls	查看所有集群节点
docker node rm	删除某个节点（-f强制删除）
docker node inspect	查看节点详情
docker node demote	节点降级，由管理节点降级为工作节点
docker node promote	节点升级，由工作节点升级为管理节点
docker node update	更新节点
docker node ps	查看节点中的 Task 任务

#### docker service
docker service create	部署服务
docker service inspect	查看服务详情
docker service logs	产看某个服务日志
docker service ls	查看所有服务详情
docker service rm	删除某个服务（-f强制删除）
docker service scale	设置某个服务个数
docker service update	更新某个服务

#### docker machine
docker-machine create	创建一个 Docker 主机（常用-d virtualbox）
docker-machine ls	查看所有的 Docker 主机
docker-machine ssh	SSH 到主机上执行命令
docker-machine env	显示连接到某个主机需要的环境变量
docker-machine inspect	输出主机更多信息
docker-machine kill	停止某个主机
docker-machine restart	重启某台主机
docker-machine rm	删除某台主机
docker-machine scp	在主机之间复制文件
docker-machine start	启动一个主机
docker-machine status	查看主机状态
docker-machine stop	停止一个主机

### swarm 集群节点可视化工具
portainer : 很强大的工具,可以监控本机和远程服务器或者集群环境,远程 docker 主机的话需要远程 docker 主机开启在 2375 端口的服务

https://www.portainer.io/installation/

```yaml
    version: '3'
    services:
      portainer:
        image: 34.0.7.183:5000/joylau/portainer:latest
        container_name: portainer
        ports:
          - 80:9000
        restart: always
        volumes:
          - /home/liufa/portainer/data:/data
```