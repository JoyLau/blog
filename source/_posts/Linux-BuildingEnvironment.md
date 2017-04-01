---
title: Linux菜鸟到熟悉 --- 生产环境的搭建
date: 2017-2-23 13:20:42
description: "之所以购买云服务器，主要是方便,安全,选择linux作为生产环境的系统更是安全，高效"
categories: [Linux篇]
tags: [Linux,JDK,Tomcat,MySQL,Redis,Docker]
---

<!-- more -->
![Server](//image.joylau.cn/blog/server.jpg)


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


### 遇到2个很尴尬的问题
- 这个问题我尝试过很多次，那就是Tomcat启动的特别慢，后来查看日志发现是部署项目的时候花费时间特别长，详细看[这里](http://bbs.qcloud.com/thread-25271-1-1.html)
- 遇到无法启动的问题，最后是`startup.sh`没有权限，你知道该怎么做的~~




## Mysql5.7数据库安装

### 说明
- mysql主要有2种方式安装
    - 1.本文要说明的
    - 2.[点击这里查看](http://blog.sina.com.cn/s/blog_16392bde40102wol6.html)


### 开始
- 在mysql的官网上找到mysql的源链接

![Mysql官网截图](//image.joylau.cn/blog/mysqlsourceLink.jpg)

- 找到原链接：`https://repo.mysql.com//mysql57-community-release-el7-9.noarch.rpm`

### 安装

- 安装命令
    ``` bash
        # wget https://repo.mysql.com//mysql57-community-release-el7-9.noarch.rpm
        # rpm -ivh mysql57-community-release-el7-9.noarch.rpm
        # yum install mysql-community-server
    ```
    
- 安装过程中有确认操作，一律***y***
- 接下来就是漫长的下载，只需要等待即可。
### 启动
- 安装完成后： `systemctl start mysqld` 启动mysqld服务
 
### 配置
- 查看` /var/log/mysqld.log `里的日志(可以查找**password**关键字)
![mysqlLog](//image.joylau.cn/blog/mysqllog.jpg)
- 可以看到创建的临时密码
- 登录MySQL：`mysql -u root -p `
- 输入刚才在日志里看到的临时密码
- 这个时候我输入任何的命令都会提示`You must reset your password using ALTER USER statement before executing this statement.`
![alterTips](//image.joylau.cn/blog/alertTips.jpg)
- 通过 `alter user 'root'@'localhost' identified by 'root'` 命令，修改 root 用户的密码为 root，注意修改的密码不能过于简单
- 退出，重新以root用户和刚设置的密码进行登录即可

### MySql配置文件

- 将所有权限赋给root用户并提供外网访问
    ``` bash
        grant all privileges on *.* to root@'%'identified by 'root';
    ```
    
- 紧接着就可以在自己的机器上用**Navicat**了
- 配置my.cnf：`/etc/my.cnf`
    ``` bash
        [mysqld]
        #
        # Remove leading # and set to the amount of RAM for the most important data
        # cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
        # innodb_buffer_pool_size = 128M
        #
        # Remove leading # to turn on a very important data integrity option: logging
        # changes to the binary log between backups.
        # log_bin
        #
        # Remove leading # to set options mainly useful for reporting servers.
        # The server defaults are faster for transactions and fast SELECTs.
        # Adjust sizes as needed, experiment to find the optimal values.
        # join_buffer_size = 128M
        # sort_buffer_size = 2M
        # read_rnd_buffer_size = 2M
        datadir=/var/lib/mysql
        socket=/var/lib/mysql/mysql.sock
        //设置端口号
        port= 3333
        
        //设置服务器端编码
        character-set-server=utf8
        
        //Linux下表名是严格区分大小写的，设置为0表示区分，设置为1表示不区分
        lower_case_table_names= 1
        
        # Disabling symbolic-links is recommended to prevent assorted security risks
        symbolic-links=0
        
        log-error=/var/log/mysqld.log
        pid-file=/var/run/mysqld/mysqld.pid
    ```
    
    
### MySQL卸载
- `yum remove  mysql mysql-server mysql-libs mysql-server;`
- `rpm -qa|grep mysql`(查询出来的东东yum remove掉)
- `find / -name mysql` (将找到的相关东西delete掉；)



### 值得注意的是：
- 1.`show variables like 'character%';`可以看到数据库的编码方式
    - `其中，character_set_client为客户端编码方式；`
    - `character_set_connection为建立连接使用的编码；`
    - `character_set_database数据库的编码；`
    - `character_set_results结果集的编码；`
    - `character_set_server数据库服务器的编码；`
    - `只要保证以上四个采用的编码方式一样，就不会出现乱码问题。`
- 2.暂时能配置只有这些，以后有更新，我会加上的



## Redis的安装

### 说明
#### Linux安装redis是需要在官网下载redis的源码然后再编译的
- redis的官网：https://redis.io/
- redis中文网：http://www.redis.cn/
- 我已将编译好直接可以使用的Redis上传到GitHub: https://github.com/JoyLau/Redis-3.2.8-Linux
- 请结合本篇博客和项目里的README文件使用

### 下载安装
- 下载linux版的压缩包,截止到我写博客的时间，官网给的稳定版是3.2.8，我们就下载`redis-3.2.8.tar.gz`
- `tar -zxvf redis-3.2.8.tar.gz`
- 进入src目录：`cd redis-3.2.8/src`
- `make` 编译
- 这时我们不执行`make intsall`,因为该操作会把编译生成的**_重要的文件_**拷贝到`user/local/bin`下，我们想要自定义配置路径

#### 注意
- 中间可能报`/bin/sh: cc:未找到命令`,对于这样的情况只需要
    ``` bash
        yum install gcc 
        yum install gcc-c++ 
    ```
    
- 这里的重要文件指的是下图所示的8个文件，在redis以前版本好像是7个文件（没具体试过）
- 注意文件和文件夹的权限

### 路径配置
- `ls`查看src下的文件，你会看到有些文件是绿色的，这些事重要的文件，也正是我们所需要的，我们将这些文件单独存下来
![Redis源码编译后的重要文件](//image.joylau.cn/blog/redisimportantfile.png)
- 我们来看看编译出来的几个程序分别是干什么的：
      redis-server：顾名思义，redis服务
      redis-cli：redis client，提供一个redis客户端，以供连接到redis服务，进行增删改查等操作
      redis-sentinel：redis实例的监控管理、通知和实例失效备援服务
      redis-benchmark：redis的性能测试工具
      redis-check-aof：若以AOF方式产生日志，当意外发生时用来快速修复
      redis-check-rdb：若以RDB方式产生日志，当意外发生时用来快速修复
- 保存好之后我们的路径如下：
![Redis根目录](//image.joylau.cn/blog/redisfloder.png)
![Redis-bin](//image.joylau.cn/blog/redisbin.png)
![Redis-etc](//image.joylau.cn/blog/redisetc.png)


### 配置文件配置
- redis.conf我只修改了以下配置
    - `port` : 端口
    - `requirepass` 密码
    - `bind 0.0.0.0` ： 配置外网可访问
    - `daemonize yes` : 将redis服务作为守护进程,作为开机启动
- 有了基本配置，redis还需要有一个管理启动、关闭、重启的一个脚本。redis源码里其实已经提供了一个初始化脚本`redis_init_script`,这是我的配置
    ``` bash
        #!/bin/sh
        # chkconfig: 2345 90 10 
        # description: Redis is a persistent key-value database
        # Simple Redis init.d script conceived to work on Linux systems
        # as it does use of the /proc filesystem.
        # 如果redis设置了密码，则$CLIEXEC -a $PASSWORD -p $REDISPORT shutdown 需要加一个参数
        
        REDISPORT=6379
        PASSWORD=123
        EXEC=/project/redis3.2.8/bin/redis-server
        CLIEXEC=/project/redis3.2.8/bin/redis-cli
        
        PIDFILE=/var/run/redis_${REDISPORT}.pid
        CONF=/project/redis3.2.8/etc/redis.conf
        
        case "$1" in
            start)
                if [ -f $PIDFILE ]
                then
                        echo "$PIDFILE exists, process is already running or crashed"
                else
                        echo "Starting Redis server..."
                        $EXEC $CONF
                fi
                ;;
            stop)
                if [ ! -f $PIDFILE ]
                then
                        echo "$PIDFILE does not exist, process is not running"
                else
                        PID=$(cat $PIDFILE)
                        echo "Stopping ..."
                        $CLIEXEC -a $PASSWORD -p $REDISPORT shutdown
                        while [ -x /proc/${PID} ]
                        do
                            echo "Waiting for Redis to shutdown ..."
                            sleep 1
                        done
                        echo "Redis stopped"
                fi
                ;;
            *)
                echo "Please use start or stop as first argument"
                ;;
        esac

    ```
    
- 头部的chkconfig的添加是为了保证`chkconfig redis on`能够执行
- 接着将**redis_init_script**脚本拷贝到**/etc/init.d/redis**，这里重命名为redis
    ``` bash
        # cp /project/redis-3.2.8/utils/redis_init_script /etc/init.d/redis
    ```
    
- 现在还缺一个系统启动时的配置:`chkconfig redis on`
- 执行之后，redis便是以系统服务启动、关闭了
    ``` bash
        systemctl start redis;
        systemctl stop redis;
        systemctl restart redis;
    ```
 



    



    
    

 
   
   