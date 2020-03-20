---
title: Linux 定时删除 10 天前的日志文件
date: 2018-12-13 15:23:09
description: 我们的程序在 Linux 上运行会产生大量日志文件,这些日志文件如果不定时清理的话会很快将磁盘占满
categories: [Linux篇]
tags: [Linux,Cron]
---

<!-- more -->

## 背景
我们的程序在 Linux 上运行会产生大量日志文件,这些日志文件如果不定时清理的话会很快将磁盘占满


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

```bash
    10 0 * * * /home/liufa/app/cron/del_log.sh > /dev/null 2>&1 &
```

```bash
    10 0 * * * root sh /home/liufa/app/cron/del_log.sh > /dev/null 2>&1 &
```

每天 0 点 10 分运行上述命令文件

2. 创建文件: del_log.sh

3. 授权 `chmod +x ./del_log.sh`

4. 删除 10 天的日志文件 

```bash
    #!/usr/bin/env bash
    find /home/liufa/app/node/logs -mtime +10 -name "*.log" -exec rm -rf {} \;
```

4. 重启定时任务, `systemctl restart crond` , 在 Ubuntu 上叫 cron `systemctl restart cron`


### 关于定时任务的配置目录
1. `/etc/crontab` 文件, 系统级别的定时任务,需要加入用户名
2. `/var/spool/cron` 目录, 以用户作为区分,一般会有一个和用户名相同的文件,里面记录了定时任务, 一般使用 crontab -e 创建, 语法中不需要指定用户名
3. `/etc/cron.d/` 和 crontab 文件类似,需要指定用户名

cron执行时，也就是要读取三个地方的配置文件

### 注意
1. 执行脚本使用/bin/sh（防止脚本无执行权限），要执行的文件路径是从根开始的绝对路径（防止找不到文件）
2. 尽量把要执行的命令放在脚本里，然后把脚本放在定时任务里。对于调用脚本的定时任务，可以把标准输出错误输出重定向到空。
3. 定时任务中带%无法执行，需要加\转义
4. 如果时上有值，分钟上必须有值
5. 日和周不要同时使用，会冲突
6. `>>` 与 `>/dev/null 2>&1` 不要同时存在


### 日志位置
日志位置位于 **/var/log/cron.log**,如果没有看到日志,可能由于没有开启 cron 日志记录,开启方法: 

`vim /etc/rsyslog.d/50-default.conf`

/var/log/cron.log相关行，将前面注释符#去掉

重启 rsyslog

`service rsyslog  restart`

或者查看系统日志, 使用命令:

`grep cron /var/log/syslog`

能看到和 cron 相关的日志信息


### 任务脚本中变量不生效
在脚本里除了一些自动设置的全局变量,可能有些变量没有生效, 当手动执行脚本OK，但是crontab死活不执行时,在脚本里使用下面的方式

1）脚本中涉及文件路径时写全局路径；
2）脚本执行要用到java或其他环境变量时，通过source命令引入环境变量

```bash
    #!/bin/sh
    source /etc/profile
    
```

3) */1 * * * * . /etc/profile;/bin/sh /path/run.sh