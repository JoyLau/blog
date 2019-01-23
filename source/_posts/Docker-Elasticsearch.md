---
title: Docker elasticsearch 集群搭建记录
date: 2019-01-23 14:59:43
description: 记录下自己使用 docker 搭建 elasticsearch 集群环境的记录
categories: [Docker篇]
tags: [Docker,Elasticsearch]
---

<!-- more -->
### .env

``` .env
    PRIVATE_REPO=34.0.7.183:5000
    ES_VERSION=6.4.3
    ELASTICSEARCH_CLUSTER_DIR=/Users/joylau/dev/idea-project/dev-app/es-doc-office/elasticsearch-cluster
```

### docker-compose.yml

``` yaml
    version: '2.2'
    services:
      node-0:
        image: ${PRIVATE_REPO}/joylau/es-doc:${ES_VERSION}
        container_name: node-0
        ports:
          - 9200:9200
          - 9300:9300
        restart: always
        volumes:
          - ${ELASTICSEARCH_CLUSTER_DIR}/data/node-0:/usr/share/elasticsearch/data
          - ${ELASTICSEARCH_CLUSTER_DIR}/logs/node-0:/usr/share/elasticsearch/logs
        environment:
          - bootstrap.memory_lock=true
          - cluster.name=es-doc-office
          - node.name=node-0
          - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
        ulimits:
          memlock:
            soft: -1
            hard: -1
        networks:
          - esnet
      node-1:
        image: ${PRIVATE_REPO}/joylau/es-doc:${ES_VERSION}
        container_name: node-1
        restart: always
        ports:
          - 9201:9200
          - 9301:9300
        volumes:
          - ${ELASTICSEARCH_CLUSTER_DIR}/data/node-1:/usr/share/elasticsearch/data
          - ${ELASTICSEARCH_CLUSTER_DIR}/logs/node-1:/usr/share/elasticsearch/logs
        environment:
          - bootstrap.memory_lock=true
          - cluster.name=es-doc-office
          - node.name=node-1
          - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
          - "discovery.zen.ping.unicast.hosts=node-0"
        ulimits:
          memlock:
            soft: -1
            hard: -1
        networks:
          - esnet
      node-2:
        image: ${PRIVATE_REPO}/joylau/es-doc:${ES_VERSION}
        container_name: node-2
        ports:
          - 9202:9200
          - 9302:9300
        restart: always
        volumes:
          - ${ELASTICSEARCH_CLUSTER_DIR}/data/node-2:/usr/share/elasticsearch/data
          - ${ELASTICSEARCH_CLUSTER_DIR}/logs/node-2:/usr/share/elasticsearch/logs
        environment:
          - bootstrap.memory_lock=true
          - cluster.name=es-doc-office
          - node.name=node-2
          - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
          - "discovery.zen.ping.unicast.hosts=master,node-1"
        ulimits:
          memlock:
            soft: -1
            hard: -1
        networks:
          - esnet
      node-3:
        image: ${PRIVATE_REPO}/joylau/es-doc:${ES_VERSION}
        container_name: node-3
        ports:
          - 9203:9200
          - 9303:9300
        restart: always
        volumes:
          - ${ELASTICSEARCH_CLUSTER_DIR}/data/node-3:/usr/share/elasticsearch/data
          - ${ELASTICSEARCH_CLUSTER_DIR}/logs/node-3:/usr/share/elasticsearch/logs
        environment:
          - bootstrap.memory_lock=true
          - cluster.name=es-doc-office
          - node.name=node-3
          - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
          - "discovery.zen.ping.unicast.hosts=master,node-1,node-2"
        ulimits:
          memlock:
            soft: -1
            hard: -1
        networks:
          - esnet
      node-4:
        image: ${PRIVATE_REPO}/joylau/es-doc:${ES_VERSION}
        container_name: node-4
        ports:
          - 9204:9200
          - 9304:9300
        restart: always
        volumes:
          - ${ELASTICSEARCH_CLUSTER_DIR}/data/node-4:/usr/share/elasticsearch/data
          - ${ELASTICSEARCH_CLUSTER_DIR}/logs/node-4:/usr/share/elasticsearch/logs
        environment:
          - bootstrap.memory_lock=true
          - cluster.name=es-doc-office
          - node.name=node-4
          - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
          - "discovery.zen.ping.unicast.hosts=master,node-1,node-3"
        ulimits:
          memlock:
            soft: -1
            hard: -1
        networks:
          - esnet
    networks:
      esnet:
```


### 问题
1. 挂载的日志和数据文件的权限
2. `vm.max_map_count ` 数目的设置
3. mac 环境下注意配置 docker 的内存大小设置

### env.init

``` bash
    #!/usr/bin/env bash
    mkdir -p /home/liufa/es-data/data/{node-0,node-1,node-2,node-3,node-4} && echo es-data directory created success || echo es-data directory created failure && \
    mkdir -p /home/liufa/es-data/logs/{node-0,node-1,node-2,node-3,node-4} && echo es-logs directory created success || echo es-logs directory created failure && \
    groupadd elasticsearch && \
    useradd elasticsearch -g elasticsearch && \
    chown -R elasticsearch:elasticsearch /home/liufa/es-data/* && \
    chmod -R 777 /home/liufa/es-data/* && \
    echo 'vm.max_map_count=262144' >> /etc/sysctl.conf && \
    sysctl -p
```

