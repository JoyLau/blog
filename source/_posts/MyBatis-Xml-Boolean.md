---
title: MyBatis xml 传 boolean 布尔类型
date: 2021-12-30 10:14:25
description: Mybatis xml 传 boolean 布尔类型
categories: [MyBatis篇]
tags: [MyBatis]
---

<!-- more -->

使用 choose 标签
```xml
<choose>
    <when test="isReSend">
        and (info.batchId is not null)
    </when>
    <otherwise>
        and (info.batchId = '' or info.batchId is null)
    </otherwise>
</choose>
```

或者


```xml
<choose>
    <when test="isReSend==true">
        and (info.batchId is not null)
    </when>
    <otherwise>
        and (info.batchId = '' or info.batchId is null)
    </otherwise>
</choose>
```