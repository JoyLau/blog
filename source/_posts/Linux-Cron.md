---
title: Linux 定时删除 10 天前的日志文件
date: 2018-12-13 15:23:09
description: 我们的程序在 Linux 上运行会产生大量日志文件,这些日志文件如果不定时清理的话会很快将磁盘沾满
categories: [Linux篇]
tags: [Linux,Crond]
---

<!-- more -->

## 背景
我们的程序在 Linux 上运行会产生大量日志文件,这些日志文件如果不定时清理的话会很快将磁盘沾满

## 配置
### 配置一个定时清理的任务
1. `crontab -e` , 添加一个定时任务

``` bash
    10 * * * * /home/liufa/app/cron/del_log.sh
```

每天 0 点 10 分运行上述命令文件

2. 创建文件: del_log.sh

3. 删除 10 天的日志文件 

``` bash
    #!/usr/bin/env bash
    find /home/liufa/app/node/logs -mtime +10 -name "*.log" -exec rm -rf {} \;
```

4. 启动定时任务, `systemctl start crond`
