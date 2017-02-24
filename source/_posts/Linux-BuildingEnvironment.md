---
title: Linux菜鸟到熟悉---生产环境的搭建
date: 2017-2-23 13:20:42
description: "之所以购买云服务器，主要是方便,安全,选择linux作为生产环境的系统更是安全，高效"
categories: [Linux篇]
tags: [linux,jdk,Tomcat]
---

<!-- more -->
![Server](http://image.lfdevelopment.cn/blog/server.jpg)


## 前言

- 本次搭建`Java`和`Tomcat`的运行环境，后续将接着搭建Mysql，Git,Nginx,Redis,Docker...环境


## Java环境搭建

- 1.在/usr/目录下创建java目录
    ``` bash
        [root@JoyLau ~]# mkdir/usr/java
        [root@JoyLau ~]# cd /usr/java
    ```
    
- 2.官网下载jdk,拷贝到服务器上，然后解压
    ``` bash
           [root@JoyLau java]# tar -zxvf jdk-8u121-linux-x64.gz
    ```
    
- 3.设置环境变量
    ``` bash
            [root@JoyLau java]# vi /etc/profile
    ```
     
- 4.在profile中添加如下内容:
    ``` bash
      #set java environment
      JAVA_HOME=/usr/java/jdk1.8.0_121
      JRE_HOME=/usr/java/jdk1.8.0_121
      CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
      PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
      export JAVA_HOME JRE_HOME CLASS_PATH PATH
      
   ```
   
- 5.让修改生效:
    ``` bash
      [root@JoyLau java]# source /etc/profile
     
     ```
   
- 6.验证
    ``` bash
        [root@JoyLau ~]# java --version
        java version "1.8.0_121"
        Java(TM) SE Runtime Environment (build 1.8.0_121-b13)
        Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode)
    ```
    
- 还有2中方法可以安装jdk：
    - 1.用`yum`安装jdk
    - 2.`Ubuntu` 上使用`apt-get`安装jdk
    
    
## Tomcat环境搭建

### 先配置

- 配置catalina.sh,加入以下配置
    ``` bash
        #add JAVA and TOMCAT config
        JAVA_OPTS="-Xms512m -Xmx1024m -Xss1024K -XX:PermSize=512m -XX:MaxPermSize=1024m"
        export TOMCAT_HOME=/project/apache-tomcat-8.5.11
        export CATALINA_HOME=/project/apache-tomcat-8.5.11
        export JRE_HOME=/usr/java/jdk1.8.0_121/jre
        export JAVA_HOME=/usr/java/jdk1.8.0_121
        
        #add tomcat pid
        CATALINA_PID="$TOMCAT_HOME/tomcat.pid"
    ```
    
    
- 增加tomcat.service在`/usr/lib/systemd/system`目录下增加`tomcat.service`，目录必须是绝对目录。
    ``` bash
        [Unit]
        Description=Tomcat
        After=syslog.target network.target remote-fs.target nss-lookup.target
         
        [Service]
        Type=forking
        PIDFile=/project/apache-tomcat-8.5.11/tomcat.pid
        ExecStart=/project/apache-tomcat-8.5.11/bin/startup.sh 
        ExecReload=/bin/kill -s HUP $MAINPID
        ExecStop=/bin/kill -s QUIT $MAINPID
        PrivateTmp=true
         
        [Install]
        WantedBy=multi-user.target 
    ```
### 再使用
- 配置开机启动 `systemctl enable tomcat`
- 启动tomcat `systemctl start tomcat`
- 停止tomcat `systemctl stop tomcat`
- 重启tomcat `systemctl restart tomcat`
    
   
### 说明
- 因为配置pid，在启动的时候会再tomcat根目录生成tomcat.pid文件，停止之后删除
- 同时tomcat在启动时候，执行start不会启动两个tomcat，保证始终只有一个tomcat服务在运行
- 多个tomcat可以配置在多个目录下，互不影响。




## Mysql5.7数据库安装

### 说明
- mysql主要有2种方式安装
    - 本文要说明的
    - [点击跳转](http://blog.sina.com.cn/s/blog_16392bde40102wol6.html)


### 开始
- 在mysql的官网上找到mysql的源链接

![Mysql官网截图](http://image.lfdevelopment.cn/blog/server.jpg)



......    未完待续     .......


    
    

 
   
   