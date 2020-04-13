---
title: 日常折腾之 KVR 漫游(二) --- 利用新路由 3 (Newifi D2) 组 KVR Wi-Fi 漫游
date: 2020-04-14 12:59:56
description: 继续上篇文章来写, 本次基于 Breed 系统刷入集客 AP 系统, 来完成 KVR 漫游配置
categories: [日常折腾篇]
tags: [KVR]
---

<!-- more -->

## 背景
继续上篇文章来写, 本次基于 Breed 系统刷入集客 AP 系统, 来完成 KVR 漫游配置


## 材料
1. 集客 AP 固件 GECOOS_AP243P_mt7621_LLELL_5.8_2020013000.bin : http://file.cnrouter.com/index.php/Index/index.html?model_id=40&device_type_id=6

我目前为止下载的版本为: 5.8_2020013000

## 步骤
1. 打开 Breed 管理界面: http://192.168.1.1
2. 选择固件,上传
3. 耐心等待重启
4. 由于 AP 没有 DHCP 功能, 没有自动分配 IP, 我们需要手动将 ip 设置为 6.6.6.x 网段, 子网掩码: 255.255.255.0, 网关不填
5. 浏览器访问: http://6.6.6.6, 默认密码为 admin

这时前期工作已经完成, 可以把路由器接入家里的主路由了


## 配置 AP
1. 首先进入系统管理设置设备名称和重新修改密码
2. 进入无线管理->SSID 设置WIFI 信息, 只要设置一台即可,下面通过克隆的方式来配置其他的 AP
3. 进入微AC->AP列表

![配置信息如下](//image.joylau.cn/blog/Daily-KVR-NewifiD2-JiKe.png)



## 注意
1. 我三台 新路由 3,其中有一台是 1.1 版本的,无法开启 5G WIFI
新路由 3 版本识别:
查询路由器底部 SN 前三位:
PND: 1.1
MND: 1.1+
HND: 1.2

2. 注意 WIFI 切换不同的信道,防止互相干扰

![信道切换](//image.joylau.cn/blog/Daily-KVR-NewifiD2-JiKe-2.png)

之后可以使用 WIFI 魔盒对家里的各个地方进行网速和稳定性及漫游的测试了✿✿ヽ(°▽°)ノ✿