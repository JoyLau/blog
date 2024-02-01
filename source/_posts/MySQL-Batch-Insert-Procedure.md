---
title: MySQL 批量插入表数据的存储过程写法记录
date: 2024-01-05 15:36:08
description: MySQL 批量插入表数据的存储过程写法记录
categories: [MySQL篇]
tags: [MySQL]
---

### 写法记录

``` sql
CREATE PROCEDURE insert_bulk(in max_num int(10))
begin
    declare i int default 0;
    set autocommit = 0;
    repeat
        set i = i + 1;
        INSERT INTO `table`(xxx) VALUES (xxx);
    until i = max_num end repeat;
    commit;
end;
```

<!-- more -->

### 调用
``` sql
call insert_bulk(10000)
```
