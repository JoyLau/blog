---
title: MySQL SQL 执行性能分析方法
date: 2024-02-05 11:02:19
description: 记录下目前用到的 MySQL SQL 执行性能分析的方法
categories: [MySQL篇]
tags: [MySQL]
---

执行性能分析，常用的方法是使用 `explain` 关键字, 但是这个方法只能看到查询的一些类型， 不能看到执行的耗时，这里我记录一些其他的方法

## MySQL 5.x 版本

```mysql
    SET profiling = 0; # 开启 session 性能记录
    # 执行 SQL
    SHOW PROFILES; # 分析性能记录

```

## MySQL 8.x 版本
在查询语句前使用 `explain analyze` 关键字

<!-- more -->

具体的结果关注实际执行时间 `actual time=8.062..8.613 rows=54 loops=1` 这样文字描述

## 查看当前连接状态

查看当前 MySQL 实例的所有连接和正在执行的语句，可以帮助发现长时间运行的查询或连接堆积问题：

```mysql
SHOW FULL PROCESSLIST;
```

重点关注 `Time`（执行时间）和 `State`（执行状态）字段，对于长时间运行的查询可以进一步分析或考虑终止。

## InnoDB 配置参数查看

### 查看 Buffer Pool 大小

Buffer Pool 是 InnoDB 存储引擎的核心缓存区域，合理配置大小对性能至关重要：

```mysql
SELECT
  @@innodb_buffer_pool_size/1024/1024 AS MB,
  @@innodb_buffer_pool_size/1024/1024/1024 AS GB;
```

配置 innodb_buffer_pool_size 方法  

```ini
# 设置8G
innodb_buffer_pool_size=8589934592
# 避免双写入缓冲
innodb_flush_method=O_DIRECT
# 设置为 0：事务提交时，日志不刷新到磁盘，只有每秒进行一次刷新。这提供了最低的持久性，但提供了最好的性能。
innodb_flush_log_at_trx_commit=0
```

## Performance Schema 性能分析

MySQL 的 Performance Schema 提供了丰富的性能监控数据。

### 查询语句执行统计

查看平均执行时间最长的 SQL 语句：

```sql
SELECT
    DIGEST_TEXT,
    COUNT_STAR,
    AVG_TIMER_WAIT/1000000000000 avg_time_s,
    MAX_TIMER_WAIT/1000000000000 max_time_s
FROM performance_schema.events_statements_summary_by_digest
ORDER BY AVG_TIMER_WAIT DESC
LIMIT 50;
```

- `DIGEST_TEXT`：SQL 语句的摘要形式
- `COUNT_STAR`：执行次数
- `AVG_TIMER_WAIT`：平均等待时间（秒）
- `MAX_TIMER_WAIT`：最大等待时间（秒）

### 清空性能统计表

如果需要重新统计，可以清空所有性能表：

```sql
CALL sys.ps_truncate_all_tables(true);
```


