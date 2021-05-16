---
title: OpenVPN 客户端创建多个网络适配器
date: 2021-02-03 12:00:01
description: OpenVPN 客户端创建多个网络适配器
categories: [OpenVPN篇]
tags: [OpenVPN]
---

<!-- more -->

## 说明
Open VPN 的客户端不做特殊配置无法同时连接多个服务器，会出现异常。提示设备已在使用

## 解决
进入 openVPN 的安装目录，以管理员的身份执行 addtap.bat 文件即可， 可在网络适配器里看到多出一块虚拟网卡