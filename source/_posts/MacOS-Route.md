---
title: MacOS 上路由表的操作记录
date: 2018-12-14 16:04:39
description: 记录下 MacOS 上关于路由的记录
categories: [MacOS篇]
tags: [MacOS]
---

<!-- more -->

1. 查看路由表: `netstat -nr`

2. 添加路由: `sudo route add 34.0.7.0 34.0.7.1`

3. 删除路由: `sudo route delete 0.0.0.0`

4. 清空路由表: `networksetup -setadditionalroutes "Ethernet"`,  “Ethernet” 指定路由走哪个设备（查看当前的设备可以使用这个命令 `networksetup -listallnetworkservices` 

### 无线网卡和 USB 有线网卡同时使用
我这里的使用场景是无线接外网, USB 网卡接内网,无线路由的网关是 192.168.0.1, USB 网卡的网关是 34.0.7.1

1. 删除默认路由: `sudo route delete 0.0.0.0`

2. 添加默认路由走无线网卡: `sudo route add 0.0.0.0 192.168.0.1`

3. 内网走 USB 网卡: `sudo route add 34.0.7.0 34.0.7.1`

4. 调整网络顺序,网络属性里面的多个网卡的优先级顺序问题。基本原则是哪个网卡访问互联网，他的优先级就在上面就可以了

> 有个问题没搞明白, 按逻辑说这样添加的静态路由是临时的,在重启后会消失失效,可实际上我重启了之后并没有失效

### 配置永久静态路由
1. `networksetup` mac 自带的工具,升级到最新的Sierra后拥有,是个“系统偏好设置”中网络设置工具的终端版

2. `networksetup –help` 可以查看具体的帮助

3. 添加静态永久路由: `networksetup -setadditionalroutes "USB 10/100/1000 LAN" 10.188.12.0 255.255.255.0 192.168.8.254`
    “USB 10/100/1000 LAN” 指定路由走哪个设备（查看当前的设备可以使用这个命令 `networksetup -listallnetworkservices` 

4. `netstat -nr` 查看路由表