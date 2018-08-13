---
title: Elasticsearch 查询全部数据
date: 2018-08-09 15:27:16
description: 记录下 ES 查询全部数据的 API 使用用法
categories: [大数据篇]
tags: [Elasticsearch]
---

<!-- more -->
### 背景
有时我们希望查询 固定条件下的全部数据
ES 默认的策略是返回10条数据
虽然可以 setSize()
但是默认上限是 10 万还是 100 万条数据,这不够优雅,一般不这么干

### TransportClient 方法

``` java
    TimeValue keepAlive = TimeValue.timeValueMinutes(30);
        SearchRequestBuilder searchRequest = client.prepareSearch(ES_KNOWLEDGE_INDEX)
                .setScroll(keepAlive)
                .setSize(10000);
        SearchResponse searchResponse = searchRequest.get();
        do {
            //处理的业务 saveIds(searchResponse);
            searchResponse = client.prepareSearchScroll(searchResponse.getScrollId()).setScroll(keepAlive).execute()
                    .actionGet();
        } while (searchResponse.getHits().getHits().length != 0);
```