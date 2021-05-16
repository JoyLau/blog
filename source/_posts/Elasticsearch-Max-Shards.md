---
title: Elasticsearch maximum shards open 的问题
date: 2021-03-12 10:53:54
description: Elasticsearch maximum shards open 的问题
categories: [Elasticsearch]
tags: [Elasticsearch]
---

<!-- more -->

https://www.elastic.co/guide/en/elasticsearch/reference/7.10/modules-cluster.html

修改 yml 文件：

cluster.max_shards_per_node 的配置

或者

PUT _cluster/settings

```json
    {
      "transient": {
        "cluster.max_shards_per_node": 5000
      }
    }
```
