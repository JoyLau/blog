---
title: OpenWrt --- 作为旁路网关/旁路由/透明网关供 Google TV 联网激活
date: 2023-08-14 11:03:48
description: OpenWrt 作为旁路网关/旁路由/透明网关供 Google TV 联网激活
categories: [ OpenWrt篇 ]
tags: [ OpenWrt ]
---

<!-- more -->

## 背景

家里的主路由是 iKuai 的，无法安装科学插件，于是想到使用 OpenWrt 作为旁路网关供家里的一些设备上网

我的方案是在群晖上安装 OpenWrt 系统虚拟机来做旁路由

## 折腾过的方案

一开始使用过群晖的 Docker 套件部署 clash-premium 容器用来做旁路网关  
这种方法需要注意的是需要使用 macvlan 创建一个独立的 docker 网络，用来的到和局域网同网段的新的 IP  
最终失败了，提示内核不支持的 tun 模式的功能  

后来我找了一个旧的笔记本直接运行编译后的二进制的 clash-premium 版本， 也是提示内核不支持，系统是 CentOS 7.2, clash-premium 版本是最新版

## 安装虚拟机

选择的 OpenWrt 固件: https://openwrt.mpdn.fun:8443/?dir=lede/x86_64  
选择 【高大全版】

在群晖里安装套件 Virtual Machine Manager
之后

- 新增硬盘映像，选择下载并解压出来的 img 文件
- 到【虚拟机】栏，选择【导入】虚拟机，选择从 【硬盘映像导入】
- 创建虚拟机， 这里注意在创建虚拟机时网卡记得选 e1000, 否则虚拟机运行后， OpenWrt 界面显示网络接口是 半双工的

## 修改 OpenWrt 配置

- 修改 **/etc/config/network** 网络配置文件，修改 “lan” 一栏的 IP 地址，网关，DNS, 修改完成重启
- 登录 OpenWrt， 用户名密码 root/password
- 来到【服务】- 【OpenClash】- 【配置订阅】导入配置信息，并配置自动更新
- 再来到 【插件设置】 - 【版本更新】，这里要下载 TUN 内核， 如果下载失败，点下载到本地，手动下载，并通过 【系统】- 【文件管理】上传到 **/etc/openclash/core/** 目录下， 并授权可执行, `chmod +x /etc/openclash/core/clash_tun`
- 再来到 【模式设置】选择 Fake-IP (TUN) 模式运行
- 再来到 【网络】- 【接口】LAN 接口设置， 基本设置， 关闭最下方的 DHCP 服务器， 选择 【忽略此接口】
- 最后来到 【DHCP/DNS】- 【高级设置】， 滚到最下方，添加 【自定义挟持域名】， 添加一条记录 `time.android.com 203.107.6.88 安卓时间服务器`

## 修改客户端配置
有 3 中方法可以配置
1. 可以到 iKuai 的 【网络设置 > DHCP设置 > DHCP静态分配】手动下发网关地址
2. 可以在 iKuai 的 【网络设置 > DHCP设置 > DHCP服务端】设置网关地址和首选 DNS 地址
3. 手动修改 Google TV 的网络设置为静态

因为我这里是首次激活，需要采取第一种方式或者第二种方式，后面激活成功后，可以还原配置，使用第三种方式

## 坑记录
Google TV 首次激活会联机安卓的时间服务器进行校时，不通的话会无法连接 WiFi，这就要求 WiFi 能科学上网并且能正确访问 `time.android.com`
域名解析请求是 UDP 访问方式，需要旁路网关支持 UDP 转发
而满足这个要求需要 DNS 劫持
这里有个重要的点就是，OpenClash 需要开启 Fake-IP (TUN) 模式运行，   
否则的话域名劫持无法解析，使用 `ntpdate time.android.com` 会提示 `no server suitable for synchronization found` 错误