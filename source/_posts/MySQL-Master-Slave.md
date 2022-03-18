---
title: MySQL 已经运行一段时间的主库添加从库
date: 2022-01-18 15:10:19
description: MySQL 已经运行一段时间的主库添加从库
categories: [MySQL篇]
tags: [MySQL]
---
<!-- more -->

导出主库全部数据

``` mysqldump -A -F --single-transaction --master-data=1 > /tmp/full.sql```

-A: 导出全部数据
-F: 同参数--flush-logs, dump 前生成新的 bin log 日志
--master-data=1：参数会在 sql 中打印出 binlog 的信息

例如：
```CHANGE MASTER TO MASTER_LOG_FILE='binlog.000248', MASTER_LOG_POS=156;```

当指定为 2 时，改行为注释的情况，为 1 时不注释
这时就相当于改变了从主库读取 binlog 的文件和位置信息，
之后将导出的数据导入从库

mysql -p < /tmp/full.sql

耐心的等待

完成后查看从节点的信息：

show slave status;

主要看 Master_Log_File 和 Read_Master_Log_Pos 的数据是否和上面的一致

此时再开启主从同步

start slave ;

完成；

查看信息