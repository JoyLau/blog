---
title: OpenWrt --- NewifiD2 刷机
date: 2026-01-24 11:19:52
description: NewifiD2刷机 OpenWrt
categories: [ OpenWrt篇 ]
tags: [ OpenWrt ]
---

### 资源地址
[OpenWrt-NewifiD2](https://openwrt.org/toh/lenovo/newifi_d2)  
[固件选择器](https://firmware-selector.openwrt.org/)

### 步骤
1. 刷入 breed 系统: 方法见我早年折腾的文章 [NewifiD2 刷机](https://blog.joylau.cn/2020/04/13/Daily-KVR-NewifiD2-Breed/)
2. 刷入 OpenWrt，注意要选择 newifi-d2-squashfs-sysupgrade.bin 的升级包，如果选择 kennel 包，所有的数据都不会保存，重启后配置会丢失

### 升级包
[openwrt-24.10.5-ramips-mt7621-d-team_newifi-d2-squashfs-sysupgrade.bin](https://s3.joylau.cn:9000/mdpic/picgo/2026/01/27/openwrt-24.10.5-ramips-mt7621-d-team_newifi-d2-squashfs-sysupgrade.bin)