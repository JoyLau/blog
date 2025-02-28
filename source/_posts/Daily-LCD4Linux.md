---
title: 日常折腾 --- 编译 LCD4Linux 增加 Image,VNC,X11 驱动
date: 2024-10-31 20:53:04
description: 下载源码编译 LCD4Linux 增加 Image,VNC,X11 驱动，可输出结果到图片、VNC 服务端和 X11 窗口
categories: [日常折腾篇]
tags: [日常折腾]
---

### 目的
下载源码编译 LCD4Linux 增加 Image,VNC,X11 驱动，可输出结果到图片、VNC 服务端和 X11 窗口

<!-- more -->
### 编译
#### 准备 x86 Linux 环境
准备一个 Docker CentOS 容器

`curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo`

`yum groupinstall -y "Development Tools"`

源码地址: https://github.com/jmccrohan/lcd4linux

#### 编译步骤

```shell

# 查看配置项
./configure --help

./configure --with-drivers='PNG,DPF,X11,VNC,NULL' --with-plugins='all'

./bootstrap

make

make install

```

#### 编译遇到的问题
##### /bin/sh: aclocal-1.14: command not found 提示错误，使用下面的命令解决

`autoreconf -ivf`

##### 缺少开发库

``` shell
yum install libusb-devel

yum install gd-devel

yum install libvncserver-devel
```

### 构建的成品

#### 带 PNG,DPF,X11,VNC,NULL 驱动的

```shell
LCD4Linux 0.11.0-SVN-1193
Copyright (C) 2005, 2006, 2007, 2008, 2009 The LCD4Linux Team <lcd4linux-devel@users.sourceforge.net>

available display drivers:
   DPF                 : Hacked dpf-ax digital photo frame
   Image               : PNG 
   NULL                : NULL driver for testing purposes
   X11                 : any X11 server

available plugins:
  cfg, math, string, test, time, apm, asterisk, button_exec, cpuinfo, diskstats, dvb, exec, event, fifo, file, hddtemp, huawei, i2c_sensors, iconv, imon, isdn, kvv, loadavg, meminfo, netdev, netinfo, pop3, ppp, proc_stat, raspi, sample, seti, statfs, uname, uptime, w1retap, wireless, xmms
```

[lcd4linux-PNG-DPF-X11-VNC-NULL_all-plugin.zip](https://s3.joylau.cn:9000/blog/lcd4linux-PNG-DPF-X11-VNC-NULL_all-plugin.zip)

### 仅 PNG,DPF 驱动的

```shell
LCD4Linux 0.11.0-SVN-1193
Copyright (C) 2005, 2006, 2007, 2008, 2009 The LCD4Linux Team <lcd4linux-devel@users.sourceforge.net>

available display drivers:
   DPF                 : Hacked dpf-ax digital photo frame
   Image               : PNG 

available plugins:
  cfg, math, string, test, time, apm, asterisk, button_exec, cpuinfo, diskstats, dvb, exec, event, fifo, file, hddtemp, huawei, i2c_sensors, iconv, imon, isdn, kvv, loadavg, meminfo, netdev, netinfo, pop3, ppp, proc_stat, raspi, sample, seti, statfs, uname, uptime, w1retap, wireless, xmms
```

[lcd4linux-PNG-DPF_all-plugin.zip](https://s3.joylau.cn:9000/blog/lcd4linux-PNG-DPF_all-plugin.zip)

### lib 库文件及图片文件和配置文件
运行时缺什么文件自行加入到 **/lib64** 目录下

[lcd4linux-resources.zip](https://s3.joylau.cn:9000/blog/lcd4linux-resources.zip)

### 运行
```shell
lcd4linux -f lcd4linux.conf
```

#### 参数
-F -vv 调试程序
-o /xxx/xx.png 生成图片

### OpenWRT 系统下安装包
地址: https://archive.openwrt.org/releases/23.05.5/packages/aarch64_generic/packages/



### 效果图
![lcd4linux-IMG](https://s3.joylau.cn:9000/blog/lcd4linux-IMG_9132.png)