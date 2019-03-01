---
title: Docker-Swarm 自定义服务部署的节点
date: 2019-03-01 09:19:00
description: 使用 docker stack 部署一组服务时,docker 会根据集群的每个节点的资源的情况来进行分配,作为使用者无法参与其中的分配,该怎么解决呢?
categories: [Docker篇]
tags: [Docker,Docker Swarm]
---

<!-- more -->
### 背景
使用 docker stack 部署一组服务时,docker 会根据集群的每个节点的资源的情况来进行分配,作为使用者无法参与其中的分配,该怎么解决呢?

### 环境
1. docker 1.13.0+
2. compose version 3+

### deploy mode
1. `replicated` 默认模式,可自定义服务的副本数,此模式不能决定服务部署到哪个节点上

```yaml
    deploy:
          mode: replicated
          replicas: 2
```

2. `global` 定义每个节点均部署一个服务的副本

```yaml
    deploy:
          mode: global
```

### node labels
该方法是通过给节点添加标签,然后在 yaml 文件里通过配置标签来决定服务部署到哪些节点

1. docker node ls 查看节点
2. docker node update --label-add role=service-1 nodeId 给 nodeId 的节点添加 label role=service-1, label 的形式是 map 的键值对形式
3. docker node inspect nodeId 查看节点的 labels 信息
4. docker node update --label-rm role=service-1 nodeId 删除 label

#### service 部署

```bash
    docker service create \
      --name nginx \
      --constraint 'node.labels.role == service-1' \
      nginx
```

#### stack 部署

```yaml
    deploy:
          placement:
            constraints:
              - node.labels.role == service-2
```

constraints 填写多个时，它们之间的关系是 AND;constraints 可以匹配 node 标签和  engine 标签
例如

```yaml
    deploy:
          placement:
            constraints: [node.role == manager]
```

```yaml
    deploy:
          placement:
            constraints:
              - node.role == manager
              - engine.labels.operatingsystem == ubuntu 14.04
```