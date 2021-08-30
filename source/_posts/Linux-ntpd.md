---
title: CentOS 时间同步服务器的搭建
date: 2021-08-30 15:42:06
description: CentOS 时间同步服务器的搭建
categories: [Linux篇]
tags: [linux,ntpd]
---

<!-- more -->
### 安装
```bash
   yum install ntp
```

修改配置文件 /etc/ntp.conf

将配置文件里的

```editorconfig
  server 0.centos.pool.ntp.org iburst
  server 1.centos.pool.ntp.org iburst
  server 2.centos.pool.ntp.org iburst
  server 3.centos.pool.ntp.org iburst
```

全部注释掉， 换成本地时间服务器

server 127.127.1.0 iburst

### 测试
```shell
systemctl enable ntpd
stsremctl start ntpd
```

有防火墙的需要打开 123 端口

使用 

`ntpq -p` 查看同步结果

在其他服务器上使用

`ntpdate -q ip` 测试查看结果

输出如下结果则服务器正常

```shell
  [root@TEST dns]# ntpdate -q 192.168.1.182
  server 192.168.1.182, stratum 6, offset -0.141762, delay 0.02614
  30 Aug 15:57:00 ntpdate[25093]: adjust time server 192.168.1.182 offset -0.141762 sec
```
