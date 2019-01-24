---
title: Elasticsearch analyzer 和 search_analyzer 的使用记录
date: 2019-01-24 10:43:32
description: 记录下  elasticsearch analyzer 和 search_analyzer 的区别
categories: [大数据篇]
tags: [Elasticsearch]
---

<!-- more -->
### 环境
- elasticsearch 6.4.3

### 示例
下面一段文字用 ik 进行分词

http://34.0.7.184:9200/_analyze/ POST

``` json
    {
      "analyzer": "ik_smart",
      "text": "关于加快建设合肥地铁七号线的通知说明"
    }
```

分词结果

``` json
    {
    "tokens": [
    {
    "token": "关于",
    "start_offset": 0,
    "end_offset": 2,
    "type": "CN_WORD",
    "position": 0
    }
    ,
    {
    "token": "加快",
    "start_offset": 2,
    "end_offset": 4,
    "type": "CN_WORD",
    "position": 1
    }
    ,
    {
    "token": "建设",
    "start_offset": 4,
    "end_offset": 6,
    "type": "CN_WORD",
    "position": 2
    }
    ,
    {
    "token": "合肥",
    "start_offset": 6,
    "end_offset": 8,
    "type": "CN_WORD",
    "position": 3
    }
    ,
    {
    "token": "地铁",
    "start_offset": 8,
    "end_offset": 10,
    "type": "CN_WORD",
    "position": 4
    }
    ,
    {
    "token": "七号",
    "start_offset": 10,
    "end_offset": 12,
    "type": "CN_WORD",
    "position": 5
    }
    ,
    {
    "token": "线",
    "start_offset": 12,
    "end_offset": 13,
    "type": "CN_CHAR",
    "position": 6
    }
    ,
    {
    "token": "的",
    "start_offset": 13,
    "end_offset": 14,
    "type": "CN_CHAR",
    "position": 7
    }
    ,
    {
    "token": "通知",
    "start_offset": 14,
    "end_offset": 16,
    "type": "CN_WORD",
    "position": 8
    }
    ,
    {
    "token": "说明",
    "start_offset": 16,
    "end_offset": 18,
    "type": "CN_WORD",
    "position": 9
    }
    ]
    }
```

- 这个时候如果配置的 analyzer 为 ik_smart 或者 analyzer 和 search_analyzer 都为 ik_smart, 则短语中每一个字都能搜到结果,还可以设置高亮信息来着重看一下

- 如果配置的 analyzer 为 ik search_analyzer 为 standard ,则 `通知`,`说明`,`七号` 这样的词是搜不到的,而 `线` 和 `的` 这样的词可以搜到,理解一下

http://34.0.7.184:9200/attachment_libs/_search POST

``` json
    {
      "query": {
        "multi_match": {
          "query": "关于",
          "fields": [
            "fileName^1.0"
          ],
          "type": "best_fields",
          "operator": "OR",
          "slop": 0,
          "prefix_length": 0,
          "max_expansions": 50,
          "zero_terms_query": "NONE",
          "auto_generate_synonyms_phrase_query": true,
          "fuzzy_transpositions": true,
          "boost": 1
        }
      },
      "_source": {
        "includes": [
          "fileName"
        ],
        "excludes": [
          "data"
        ]
      },
      "highlight": {
        "pre_tags": [
          "<span style = 'color:red'>"
        ],
        "post_tags": [
          "</span>"
        ],
        "fields": {
          "*": {}
        }
      }
    }
```

返回的结果为:

``` json
    {
    "took": 2,
    "timed_out": false,
    "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
    },
    "hits": {
    "total": 0,
    "max_score": null,
    "hits": [ ]
    }
    }
```

而搜索 `线` 返回的结果为:

``` json
    {
    "took": 5,
    "timed_out": false,
    "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
    },
    "hits": {
    "total": 1,
    "max_score": 0.2876821,
    "hits": [
    {
    "_index": "attachment_libs",
    "_type": "attachment_info",
    "_id": "fd45d5be-c314-488a-99d3-041acc015377",
    "_score": 0.2876821,
    "_source": {
    "fileName": "关于加快建设合肥地铁七号线的通知说明"
    },
    "highlight": {
    "fileName": [
    "关于加快建设合肥地铁七号<span style = 'color:red'>线</span>的通知说明"
    ]
    }
    }
    ]
    }
    }
```


### 总结
- 分析器主要有两种情况会被使用，一种是插入文档时，将text类型的字段做分词然后插入倒排索引，第二种就是在查询时，先对要查询的text类型的输入做分词，再去倒排索引搜索
- 如果想要让 索引 和 查询 时使用不同的分词器，ElasticSearch也是能支持的，只需要在字段上加上search_analyzer参数
    1. 在索引时，只会去看字段有没有定义analyzer，有定义的话就用定义的，没定义就用ES预设的
    2. 在查询时，会先去看字段有没有定义search_analyzer，如果没有定义，就去看有没有analyzer，再没有定义，才会去使用ES预设的