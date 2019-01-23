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


## 说明

``` bash
    # For details see man 4 crontabs
    
    # Example of job definition:
    # .---------------- minute (0 - 59)
    # |  .------------- hour (0 - 23)
    # |  |  .---------- day of month (1 - 31)
    # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
    # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
    # |  |  |  |  |
    # *  *  *  *  * user-name  command to be executed
```
## 配置
### 配置一个定时清理的任务
1. `crontab -e` , 添加一个定时任务, 或者 `vim /etc/crontab` 添加一条记录

``` bash
    10 * * * * /home/liufa/app/cron/del_log.sh > /dev/null 2>&1 &
```

```bash
    10 * * * * root sh /home/liufa/app/cron/del_log.sh > /dev/null 2>&1 &
```

每天 0 点 10 分运行上述命令文件

2. 创建文件: del_log.sh

3. 授权 `chmod +x ./del_log.sh`

4. 删除 10 天的日志文件 

``` bash
    #!/usr/bin/env bash
    find /home/liufa/app/node/logs -mtime +10 -name "*.log" -exec rm -rf {} \;
```

4. 重启定时任务, `systemctl restart crond` , 在 Ubuntu 上叫 cron `systemctl restart cron`


### 注意
1. 执行脚本使用/bin/sh（防止脚本无执行权限），要执行的文件路径是从根开始的绝对路径（防止找不到文件）
2. 尽量把要执行的命令放在脚本里，然后把脚本放在定时任务里。对于调用脚本的定时任务，可以把标准输出错误输出重定向到空。
3. 定时任务中带%无法执行，需要加\转义
4. 如果时上有值，分钟上必须有值
5. 日和周不要同时使用，会冲突
6. `>>` 与 `>/dev/null 2>&1` 不要同时存在