---
title: Crontab @reboot 设置开机启动命令
date: 2022-04-27 21:45:19
description: 有时服务器断电后再开机启动需要启动一些服务，除了正常的 rc 命令可以实现外，之前我常用的是 systemctl service, 今天发现 crontab 的 reboot 标签也可以实现
categories: [Linux篇]
tags: [Linux,Cron]
---

<!-- more -->

## 背景
有时服务器断电后再开机启动需要启动一些服务，除了正常的 rc 命令可以实现外，之前我常用的是 systemctl service, 今天发现 crontab 的 reboot 标签也可以实现


## 使用

`crontab -e`


``` bash
    # 启动后 120 秒启动 canal adapter
    @reboot sleep 120; cd /data/msmp-service/canal/canal.adapter-1.1.5/bin && sh restart.sh
    
    @reboot sleep 600; cd /data/gateway && sh handler.sh restart
```


保存后即可生效

一般情况下，我会 sleep 一段时间再启动服务，因为要等其他 systemd 服务启动完成，比如数据库服务