---
title: Ubuntu 自用配置记录
date: 2018-06-28 15:16:22
description: 安装完 Ubuntu 后自定义的一些配置记录
categories: [Ubuntu篇]
tags: [Ubuntu]

<!-- more -->

1. 关闭并禁用 swap 分区： sudo swapoff 并且 sudo vim /etc/fstab 注释掉 swap 那行

2. 开启点击图标最小化： gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-minimize-window true

3. 开机开启小键盘： sudo apt-get install numlockx 然后 sudo vim /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf 在最后添加：greeter-setup-script=/usr/bin/numlockx on

4. 用久显示隐藏文件夹： Edit -> Preferences -> Views 勾选 Show hidden and backup files

5. 禁用客人会话： https://blog.csdn.net/thuyx/article/details/78503870

6. jdk 10 的配置？？
    分别下载 jdk10 和 jre 10 解压缩到 /usr/java目录下
    配置如下环境变量

``` bash
    #set java environment
    JAVA_HOME=/usr/java/jdk-10
    JRE_HOME=/usr/java/jre-10
    CLASS_PATH=.:$JAVA_HOME/lib:$JRE_HOME/lib
    
    MAVEN_HOME=/usr/maven/apache-maven-3.5.3
    NODE_HOME=/usr/nodejs/node-v8.11.2-linux-x64
    
    PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:${NODE_HOME}/bin:$PATH
    export JAVA_HOME JRE_HOME CLASS_PATH MAVEN_HOME NODE_HOME PATH

```

7. 安装中文字体文泉译：sudo apt-get install fonts-wqy-microhei

8. 防火墙配置
    sudo ufw enable
    
    sudo ufw default deny
    
    运行以上两条命令后，开启了防火墙，并在系统启动时自动开启。关闭所有外部对本机的访问，但本机访问外部正常
    
    sudo ufw disable 关闭防火墙
    