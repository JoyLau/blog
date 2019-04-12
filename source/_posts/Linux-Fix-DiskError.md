---
title: 记录一次 Ubuntu 因磁盘问题导致开机进入紧急模式的情况
date: 2019-04-10 10:44:10
description: 记录一次 Ubuntu 因磁盘问题导致开机进入紧急模式的情况
categories: [Linux篇]
tags: [Linux,Ubuntu]
---

<!-- more -->

## 背景
在家里使用 vnc 协议远程连接公司的 Ubuntu 电脑
导致桌面卡死
期间还遇到了 搜狗输入法崩溃，提示我删除用户目录下的一个文件然后重启
鼠标可以动
界面上的任何东西都无法点击
没再操作
等第二天到公司解决

## 不重启解决 Ubuntu 桌面卡死
这样的情况遇到很多了
ctrl + alt + f1

```bash
    ps -t tty7
    
    PID TTY          TIME CMD
    1758 tty7     00:00:55 Xorg
    
    kill -9 1758

```

之后桌面上的应用都会被关闭，回到登录界面

## 重启进入紧急模式
之后我想着电脑很久没关机了，想重启一下，顺便去倒杯水
回来之后发现系统正在进行磁盘检测并且之后进入了紧急模式

`journalctl -xb` 查看启动日志

一直往下翻

发现 `/dev/sdb6` 分区出现问题导致系统无法启动

使用 `lsblk` 查看分区挂载情况

```bash
    joylau@joylau-work-192:~$ lsblk -f
    NAME   FSTYPE   LABEL    UUID                                 MOUNTPOINT
    loop1  squashfs                                               /snap/core/6405
    sdb                                                           
    ├─sdb2                                                        
    ├─sdb5 ext4              4ff695c6-b2ef-46d9-8501-c7e8ee61edda /
    ├─sdb1 ext4              98f0eb66-3d90-4bc5-a1f0-d3117de87809 /boot
    └─sdb6 ext4              76ad5dc1-37b7-4624-830b-d923dac8ac48 
    loop4  squashfs                                               /snap/redis-desktop-manager/191
    loop2  squashfs                                               /snap/core/6673
    loop0  squashfs                                               /snap/redis-desktop-manager/156
    sdc                                                           
    ├─sdc2 ntfs     新加卷   AE5CA91F5CA8E2F7                     /media/extra
    └─sdc1 ntfs     新加卷   0CBC9840BC9825EC                     
    sda                                                           
    ├─sda2 ntfs              5E68EE4D68EE240D                     
    ├─sda7 ntfs              EAD67107D670D573                     
    ├─sda5 ntfs              9E14908214905ED9                     
    ├─sda3                                                        
    ├─sda1 ntfs     系统保留 A27AE98B7AE95C93                     
    └─sda6 ntfs              E2D84A6BD84A3E53                     /media/extra_2
    loop3  squashfs             
```

## 解决问题
上面看到 sdb6 没有挂载点，实际上是有的，只不过现在出问题了没有挂载上
可以找 UUID **76ad5dc1-37b7-4624-830b-d923dac8ac48**

查看 `/etc/fstab`

```bash
    # /etc/fstab: static file system information.
    #
    # Use 'blkid' to print the universally unique identifier for a
    # device; this may be used with UUID= as a more robust way to name devices
    # that works even if disks are added and removed. See fstab(5).
    #
    # <file system> <mount point>   <type>  <options>       <dump>  <pass>
    # / was on /dev/sdb5 during installation
    UUID=4ff695c6-b2ef-46d9-8501-c7e8ee61edda /               ext4    errors=remount-ro 0       1
    # /boot was on /dev/sdb1 during installation
    UUID=98f0eb66-3d90-4bc5-a1f0-d3117de87809 /boot           ext4    defaults        0       2
    # /home was on /dev/sdb6 during installation
    UUID=76ad5dc1-37b7-4624-830b-d923dac8ac48 /home           ext4    defaults        0       2
    # swap was on /dev/sdc5 during installation
    #UUID=a99b0d98-9282-4e52-8f49-74b9b1f2ed8e none            swap    sw              0       0
    
    UUID=AE5CA91F5CA8E2F7                     /media/extra    ntfs   defaults         0       0
    UUID=E2D84A6BD84A3E53                     /media/extra_2    ntfs   defaults         0       0

```

查看到 **76ad5dc1-37b7-4624-830b-d923dac8ac48** 对应挂载的 `/home` 目录

后面的 pass 写的是 2 ，就是说开机进行磁盘检查，并且数值越小，越先检查

这里有个临时的解决方式就是将 `/home` 的 pass 改为 0 ，也就是开机不进行检查，该分区有问题并不代表分区不可用

改完后依然可以访问 `/home` 目录

## 磁盘修复
强迫症让我不能就这么将就
我觉得修复这个磁盘错误
使用命令修复这个错误如下

```bash
    fsck -y /dev/sdb6
```

结果提示 分区已挂载，操作被终止

修改 fstab 将 sdb6 挂载的那行注释
重启
进入紧急模式
运行 `fsck -y /dev/sdb6`
这时会打印很多日志
重复执行，直到没有日志打印

这时在修改 fstab, 去掉注释，pass 改为 2
重启
解决 