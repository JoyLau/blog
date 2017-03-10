---
title: Linux菜鸟到熟悉---视图界面
date: 2017-2-23 14:56:22
description: "使用Putty连接linux都是使用命令行来执行我们的操作，这个对于一个刚入手linux的新手来说会很不习惯</br>
阿里云官网默认的Linux Centos7系统镜像，都是没有安装桌面环境的，用户如果要使用桌面，需要自己在服务器上进行安装，但是在生产环境下是不推荐使用的"
categories: [Linux篇]
tags: [linux,MATE Desktop]
---

<!-- more -->
![MATE Desktop](//image.joylau.cn/blog/desktop.png)



> 上面的截图是我安装好之后界面，安装的是MATE桌面

### 说明

- 1.阿里云官网默认的Linux Centos7系统镜像，都是没有安装桌面环境的，用户如果要使用桌面，需要自己在服务器上进行安装
- 2.生产环境下不要安装桌面，毕竟生产环境下的资源都是很紧张的
- `groups`是Centos7才有的命令

### 开始安装

- 登录服务器，执行命令安装桌面环境（537M）
    ``` bash
        yum groups install "MATE Desktop"
    ```
    
- 安装好MATE Desktop 后，再安装X Window System（19M） 
    ``` bash 
        yum groups install "X Window System"
    ```

### 配置

- 设置服务器默认启动桌面 
    ``` bash
        systemctl  set-default  graphical.target
    ```
    
### 启动

- 重启服务器 
``` bash
    reboot
```

在ECS控制台,用管理终端登录服务器,进入到服务器系统登录界面，用root密码登录服务器。


### 卸载
``` bash
    yum groupremove 'X Window System' -y
    yum groupremove 'MATE Desktop' -y
    // 恢复至默认启动界面
    systemctl set-default multi-user.target
```



