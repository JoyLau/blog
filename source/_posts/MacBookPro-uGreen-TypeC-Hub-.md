---
title: MacBook Pro 使用绿联 TypeC 网卡关闭笔记本盖子时导致局域网网络不可用的问题解决
date: 2020-08-04 17:06:29
description: "MacBook Pro 使用绿联 TypeC 网卡关闭笔记本盖子时导致局域网网络不可用的问题解决"
categories: [MacOS篇]
tags: [MacOS]
---

<!-- more -->

## 问题描述
我的 MacBook Pro 使用的是绿联的外接扩展坞, 其中有一个网口
在京东购买的: https://item.jd.com/4445121.html

型号为: CM179
网卡芯片为: RTL8153B

最近发现只要我的 MacBook Pro 关闭了盖子, 会导致接在同一交换机下的路由器就无法上网
打开盖子后,网络又恢复正常了  

## 解决
搜索了一番没找到解决方式

于是就找到当时购买的这款产品的京东介绍页面看了看

想着去绿联的官网找找驱动试试: https://www.lulian.cn/download/list-34-cn.html

找到对应的型号和网卡芯片: https://www.lulian.cn/download/38-cn.html

下载并解压驱动压缩包，双击“RTUNICv1.0.20.pkg”文件，一直点击继续，安装完成后重启电脑即可。

重启后又试了下关闭盖子, 问题解决了!!!
