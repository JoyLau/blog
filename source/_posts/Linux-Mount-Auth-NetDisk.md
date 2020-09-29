---
title: Linux 挂载有用户名密码的网络磁盘
date: 2020-09-29 16:36:37
description: 很多时候我们通过 mount -t nfs -o nolock 服务端IP:共享目录绝对路径 本地挂载目录 来挂载网络磁盘， 为了安全考虑网络磁盘都设置了用户名密码， 这时....
categories: [Linux篇]
tags: [Linux]
---

<!-- more -->

## 背景
很多时候我们通过 mount -t nfs -o nolock 服务端IP:共享目录绝对路径 本地挂载目录 来挂载网络磁盘

很多时候，为了安全考虑网络磁盘都设置了用户名密码

这时挂载的时候就需要设置用户名密码了

很可惜上述方式 nfs 没有找到设置用户名密码的参数

## 解决
使用 cifs 

1. 安装依赖： `yum install cifs-utils`

2. 挂载： `mount -t cifs -o username=USERNAME,password=PASSWORD,iocharset=utf8 //192.168.10.191/CM_Backup /mnt/191-nas`

注意主机地址前的 `//` 不能省略

3. 卸载挂载： umount /mnt/191-nas

## 额外的
挂载网络磁盘很多时候无非为了备份， 使用 `cp` 命令像本地拷贝文件一样备份即可，但是 cp 命令无法显示进度，对于大文件来说，就会等待上很长的时间无输出

我这里提供 2 中解决方式

1. 使用 `pv`

语法： `pv sourcefile > targetfile`

优点： 提供实时进度条显示

缺点： 只能终端显示， 无法记录到文件中， 而且一旦终止任务， 进程无法正常退出

2. 使用 `rsync`

语法： `rsync -avPh  sourcefile  targetfile `

优点： 使用命令 `rsync -avPh  sourcefile  targetfile | tee log.log` 可将进度写入日志文件中

缺点： 暂无


