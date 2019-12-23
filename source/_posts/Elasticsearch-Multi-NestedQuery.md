---
title: Elasticsearch Nested 类型动态数据的组合查询
date: 2019-12-23 09:51:46
description: 记录下Elasticsearch Nested 类型动态数据的组合查询
categories: [大数据篇]
tags: [Elasticsearch]
---

<!-- more -->
### 背景
Nested 类型的数据不多说了,
先看 mapping:

``` json
    "metaArray": {
        "type": "nested",
        "properties": {
          "key": {
            "type": "text",
            "analyzer": "ik_max_word",
            "fields": {
              "full": {
                "type": "keyword"
              }
            }
          },
          "value": {
            "type": "text",
            "analyzer": "ik_max_word",
            "fields": {
              "full": {
                "type": "keyword"
              }
            }
          }
        }
      },
```

再看数据:

```json
    {
        "_index":"category_libs_v1.x",
        "_type":"category_info",
        "_id":"526",
        "_version":1,
        "_score":1,
        "_source":{
            "categoryName":"投标文件",
            "createTime":"2019-12-23 00:07:15",
            "id":"526",
            "metaArray":[
                {
                    "value":"Joy",
                    "key":"作者"
                },
                {
                    "value":"txt",
                    "key":"文件类型"
                }
            ],
            "pathName":"企业空间导航/业务条块",
            "pids":"|1|525|",
            "status":0,
            "updateTime":"2019-12-23 00:07:15"
        }
    }
```

### 目的
想查作者是 Joy 并且文件类型是 txt 的记录

### 方式
使用 nestedQuery + queryStringQuery

语句:

```json
    {
        "from":0,
        "size":10,
        "query":{
            "bool":{
                "must":[
                    {
                        "nested":{
                            "query":{
                                "query_string":{
                                    "query":"metaArray.key.full:作者 AND metaArray.value.full:Joy"
                                }
                            },
                            "path":"metaArray",
                            "score_mode":"max"
                        }
                    },
                    {
                        "nested":{
                            "query":{
                                "query_string":{
                                    "query":"metaArray.key.full:文件类型 AND metaArray.value.full:txt"
                                }
                            },
                            "path":"metaArray",
                            "score_mode":"max"
                        }
                    }
                ]
            }
        }
    }
```

代码:

``` java
    String key = xxxx
    String value = xxxx
    nestedQuery("metaArray", queryStringQuery("metaArray.key.full:" + key + " AND metaArray.value.full:" + value), ScoreMode.Max);
```