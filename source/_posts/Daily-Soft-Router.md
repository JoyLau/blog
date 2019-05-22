---
title: 日常折腾 --- 软路由攒机记录
date: 2019-05-22 14:45:10
img: <center><img src='http://image.joylau.cn/blog/IMG_0314.jpg' alt='IMG_0314'></center>
description: 日常折腾之家里网线改造记录
categories: [日常折腾篇]
tags: [日常折腾]
---

<!-- more -->
### 背景
上篇说到了家里使用多条宽带,而一般的路由器无法使用多个运营商的宽带进行拨号,这就需要软路由了,其实也就是个小主机

### 实机
看下我攒的把

![](http://image.joylau.cn/blog/IMG_0314.jpg)

![](http://image.joylau.cn/blog/IMG_0315.jpg)

![](http://image.joylau.cn/blog/IMG_0316.jpg)


### 硬件配置

### 主要硬件
- CPU Intel(R) Atom(TM) CPU D525 @ 1.80GHz | 512 KB | 1796 MHz | ×4
- 硬盘 ATA DragonDiamond D2 5 (3.75GB)
- 内存 2037MB
- 主板芯片：Intel Corporation Atom Processor D4xx/D5xx/N4xx/N5xx DMI Bridge (rev 02)
- 网卡：Intel Corporation 82583V Gigabit Network Connection (eth0 20:90:30:e8:2f:99)
- 网卡：Intel Corporation 82583V Gigabit Network Connection (eth1 20:90:30:e8:2f:9a)
- 网卡：Intel Corporation 82583V Gigabit Network Connection (eth2 20:90:30:e8:2f:9b)
- 网卡：Intel Corporation 82583V Gigabit Network Connection (eth3 20:90:30:e8:2f:9c)

### 其它硬件
- 显卡：Intel Corporation Atom Processor D4xx/D5xx/N4xx/N5xx Integrated Graphics Controller (rev 02)
- USB控制器：Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #4 (rev 03)
- USB控制器：Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #5 (rev 03)
- USB控制器：Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #2 (rev 03)
- USB控制器：Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #1 (rev 03)
- USB控制器：Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #2 (rev 03)
- USB控制器：Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #3 (rev 03)
- USB控制器：Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #1 (rev 03)
- PCI桥：Intel Corporation 82801H (ICH8 Family) PCI Express Port 1 (rev 03)
- PCI桥：Intel Corporation 82801H (ICH8 Family) PCI Express Port 2 (rev 03)
- PCI桥：Intel Corporation 82801H (ICH8 Family) PCI Express Port 3 (rev 03)
- PCI桥：Intel Corporation 82801H (ICH8 Family) PCI Express Port 4 (rev 03)
- PCI桥：Intel Corporation 82801H (ICH8 Family) PCI Express Port 5 (rev 03)
- PCI桥：Intel Corporation 82801 Mobile PCI Bridge (rev f3)
- IDE接口：Intel Corporation 82801HM/HEM (ICH8M/ICH8M-E) IDE Controller (rev 03)
- IDE接口：Intel Corporation 82801HM/HEM (ICH8M/ICH8M-E) SATA Controller [IDE mode] (rev 03)
- SMBus：Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 03)

### 我的使用
1. 四个网口,2 个作为 WAN 口,一个电信宽带,一个长城宽带,一个作为 LAN 口,接台式机,最后一个作为 LAN 口,接路由器的 LAN 口提供 WIFI
2. 2 个宽带使用负载均衡实现宽带叠加
3. 端口分流,实现 WIFI 设备走长城宽带的流量,台式机和一些静态的 DHCP 的 IP 走电信流量
4. 还有一些端口映射和 DMZ 主机和动态域名绑定等普通路由器的功能 (支持 阿里云的 DDNS, 提供 accessKey 和 Access Key Secret 即可)

### 花费
目前这样的配置完全跑个软路由系统绰绰有余了, 我用的是 iKuai, CPU 温度在 22 度左右, CPU 使用率低于 10%, 内存使用率 20% 左右
全部花费 234 元