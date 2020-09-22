---
title: Docker Compose Version 3 限制 CPU 和 内存的使用方法
date: 2020-09-22 11:18:12
description: 记录 Docker Compose Version 3 限制 CPU 和 内存的使用方法
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### 背景
在 docker 官方问文档里查找关于 docker compose 3 关于资源限制的配置项
发现只能用于集群部署

### 解决方式
依然使用集群部署的配置方式:

```yaml
    redis:
        image: redis:alpine
        container_name: redis
        deploy:
          resources:
            limits:
              cpus: '0.50'
              memory: 50M
```

这时启动时加入参数 `--compatibility` 即可

```bash
    docker-compose --compatibility up -d
```

`--compatibility`: 以兼容模式运行, 将 v3 的语法转化为 v2 的语法, 而不需要将 compose 文件改为 v2 的版本