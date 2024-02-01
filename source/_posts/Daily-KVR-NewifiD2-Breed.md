---
title: 日常折腾之 KVR 漫游(一) --- 新路由 3 (Newifi D2) 刷入 Breed (刷不死)固件
date: 2020-04-13 08:59:56
cover: //s3.joylau.cn:9000/blog/Daily-KVR-NewifiD2-Breed.jpeg
description: 目前想要组 WIFI 漫游可选的方案有 AC + AP 或者 mesh 组网, 可这些的价格都不便宜, 而我选择用 2 台之前很火的矿机新路由 3 (Newifi D2) 来组 AP 实现 KVR 漫游,想要组 KVR 漫游, 2 台路由必须刷入集客 AP 固件, 而刷入集客 AP 固件前必须先刷入 Breed 固件,本篇介绍新路由 3 如何刷入该固件 
categories: [日常折腾篇]
tags: [KVR]
---

<!-- more -->

## 背景
目前想要组 WIFI 漫游可选的方案有 AC + AP 或者 mesh 组网, 可这些的价格都不便宜, 而我选择用 2 台之前很火的矿机新路由 3 (Newifi D2) 来组 AP 实现 KVR 漫游
想要组 KVR 漫游, 2 台路由必须刷入集客 AP 固件, 而刷入集客 AP 固件前必须先刷入 Breed 固件
本篇介绍新路由 3 如何刷入该固件 


## 我的新路由 3

一次性搞了 3 台

![新路由 3](//s3.joylau.cn:9000/blog/Daily-KVR-NewifiD2-Breed.jpeg)


## 概念介绍
### 802.11k
通过创建优化的频道列表，802.11k 标准可帮助设备快速搜索附近可作为漫游目标的 AP。如果当前接入点的信号强度变弱，您的设备将进行扫描来确定是否有此列表中的目标接入点。

### 802.11v
具备“即将解除关联”功能的 BSS 转换管理可向网络的控制层提供附近接入点的负载信息，从而影响客户端漫游行为。设备在确定可能的漫游目标时会考量这些信息。

DMS 可优化无线网络上的多播流量传输。设备会利用这些信息来增强多播通信，并保持电池续航能力。

BSS 最大空闲服务有助于客户端和接入点在没有流量传输时，高效地决定保持关联的时长。设备会利用这些信息来保持电池续航能力。

### 802.11r
当您的设备在同一网络中从一个 AP 漫游到另一个 AP 时，802.11r 会使用一项名为“快速基本服务集转换”(FT) 的功能更快地进行认证。FT 适用于预共享密钥 (PSK) 和 802.1X 鉴定方法。

以上来自苹果官网对于 KVR 的介绍: https://support.apple.com/zh-cn/HT202628

## 步骤
### 材料准备
1. [newifi-d2-jail-break.ko](//s3.joylau.cn:9000/blog/newifi-d2-jail-break.ko)

### 操作
1. 重置现有路由器系统: 开机状态下按住 reset 键 5 秒,等待重启
2. 进入 http://192.168.99.1 初始化路由器,设置好 WIFI 和密码
3. 浏览器访问 http://192.168.99.1/newifi/ifiwen_hss.html 开启路由器的 ssh 登录, 用户名为 root ,密码为刚才设置的密码
4. 使用 scp 命令拷贝 newifi-d2-jail-break.ko 到 tmp 目录下: scp ./newifi-d2-jail-break.ko root@192.168.99.1:/tmp
5. 刷入系统: insmod /tmp/newifi-d2-jail-break.ko 
6. 等待 30 秒左右, 断电, 再按住 reset 键通电
7. 此时路由器分配的网段为 192.168.1.0
8. 访问 http://192.168.1.1 进行设置

## 注意
1. newifi-d2-jail-break.ko 是恩山论坛上一个大神破解的,如果在 Breed 官网(https://breed.hackpascal.net/)下载固件 `breed-mt7621-newifi-d2.bin`,是无法通过自身恢复模式刷入固件的,别问我怎么知道的