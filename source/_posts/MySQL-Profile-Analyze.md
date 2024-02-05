---
title: MySQL SQL 执行性能分析方法
date: 2024-02-05 11:02:19
description: 记录下目前用到的 MySQL SQL 执行性能分析的方法
categories: [MySQL篇]
tags: [MySQL]
---

执行性能分析，常用的方法是使用 `explain` 关键字, 但是这个方法只能看到查询的一些类型， 不能看到执行的耗时，这里我记录一些其他的方法

## MySQL 5.x 版本

```sql
    SET profiling = 0; # 开启 session 性能记录
    # 执行 SQL
    SHOW PROFILES; # 分析性能记录

```

## MySQL 8.x 版本
在查询语句前使用 `explain analyze` 关键字

<!-- more -->

具体的结果关注实际执行时间 `actual time=8.062..8.613 rows=54 loops=1` 这样文字描述


