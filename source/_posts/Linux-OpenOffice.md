---
title: Linux 安装 OpenOffice 服务小记
date: 2018-06-22 11:53:49
description: "最近在研究 office 套件在线预览的功能 ，在此记下安装过程和出错的解决方式"
categories: [Linux篇]
tags: [linux,openoffice]
---

<!-- more -->

### 安装步骤

1. 下载 rpm 包 ： 官网： https://www.openoffice.org/download/

2. 解压，进入 /zh-CN/RPMS/ ， 安装 rpm 包： `rpm -ivh *.rpm`

3. 安装完成后，生成 desktop-integration 目录，进入，因为我的系统是 centos 的 ，我选择安装 `rpm -ivh openoffice4.1.5-redhat-menus-4.1.5-9789.noarch.rpm`

4. 安装完成后，目录在 /opt/openoffice4 下
    启动： `/opt/openoffice4/program/soffice -headless -accept="socket,host=0.0.0.0,port=8100;urp;" -nofirststartwizard &`


### 遇到的问题
1. libXext.so.6: cannot open shared object file: No such file or directory
    解决 ： `yum install libXext.x86_64`

2. no suitable windowing system found, exiting.
    解决： `yum groupinstall "X Window System"`

之后再启动，查看监听端口 `netstat -lnp |grep 8100`
已经可以了。