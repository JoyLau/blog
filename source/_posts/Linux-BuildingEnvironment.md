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


### yum 安装jdk
- yum search jdk ： 查看yum源上的jdk版本信息
- 选择一个jdk8的来安装： yum install java-1.8.0-openjdk.x86_64
- 等待即可

注意的是默认安装的只是 Java JRE，而不是 JDK，为了开发方便，我们还是需要通过 yum 进行安装 JDK
yum install java-1.8.0-openjdk-devel.x86_64

之后就可以直接使用 Java javac 命令了

配置 JAVA_HOME变量:

vim ~/.bashrc
在文件最后面添加如下单独一行（指向 JDK 的安装位置），并保存：
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
接着还需要让该环境变量生效，执行如下代码：
source ~/.bashrc    # 使变量设置生效
设置好后我们来检验一下是否设置正确：
echo $JAVA_HOME     # 检验变量值
java -version
$JAVA_HOME/bin/java -version  # 与直接执行 java -version 一样
如果设置正确的话，$JAVA_HOME/bin/java -version 会输出 java 的版本信息，且和 java -version 的输出结果一样

### rpm 安装jdk
1. 官网下载 jdk rpm包
2. rpm -ivh jdk_xxxxx.rpm
3. 配置环境变量（和上述配置一致）
4. 卸载： rpm -qa|grep jdk ， 查出什么，就使用 rpm -e --nodeps java_xxx 来卸载

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


### 使用yum安装的tomcat注意
- 安装位置   _/etc/tomcat_
- 主程序/软件存放webapp位置   _/var/lib/tomcat/webapps_
- 在Centos使用yum安装后，Tomcat相关的目录都已采用符号链接到/usr/share/tomcat6目录，包含webapps等，这很方便我们配置管理   _/usr/share/tomcat_
- 日志记录位置   _/var/log/tomcat_
- 查看全部tomcat安装目录   _rpm -ql tomcat6 | cat -n_



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
- `rpm -qa|grep mysql`(查询出来的东西yum remove掉)
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


## FTP 服务端安装

1. yum install vsftpd
2. 修改 vim /etc/vsftpd/vsftpd.conf
    `anonymous_enable=NO` : 不允许匿名用户登录
    `chroot_local_user=YES` : 用户不能跳出当前的 home 目录
3. 安装好之后其实已经创建了个 ftp 的用户了,可以查看 /etc/passwd 文件,只是没有密码,这个时候使用 ftp 工具来登录是可以看到目录的,默认 ftp 的 home 目录在 /var/ftp/ 下    
4. 修改 ftp 用户密码 passwd ftp
5. 这时使用 ftp 用户登录,发现不能 上传文件和删除文件,有 553 错误

### 解决不能上传和删除文件
1. 首先 selinux 会默认拦截 vsftp,想要不被拦截的话,可以关闭 selinux, 但是关闭后安全性得不到保障,可能会出现其他的问题,这里我们不关闭,可以开放权限

    ``` shell
        setenforce 0 #暂时让SELinux进入Permissive模式
        getsebool -a | grep ftpd #查看 ftpd 的权限
        
        ftpd_anon_write --> off
        ftpd_connect_all_unreserved --> off
        ftpd_connect_db --> off
        ftpd_full_access --> on
        ftpd_use_cifs --> off
        ftpd_use_fusefs --> off
        ftpd_use_nfs --> off
        ftpd_use_passive_mode --> off
        
        setsebool -P ftpd_full_access 1 # 设置ftpd_full_access的权限为 on
        
        setenforce 1 # 开启 selinux
    ```

2. 这时 selinux 已经开放了 vsftpd 的权限

3. 给 ftp 用户的 home 目录赋予写的权限 chmod a+w /var/ftp

4. vsftpd 在新版本时,如果检测到用户不能跳出当前的 home 目录,那么用户的 home 不能有写的权限,会报 500 OOPS: vsftpd: refusing to run with writable root inside chroot() 错误,这时就尴尬了

5. 解决方式: 在配置文件中添加: allow_writeable_chroot=YES

6. 重启 vsftpd


## RabbitMQ 服务端安装
1. yum install rabbitmq-server
2. rabbitmq-plugins enable rabbitmq_management
3. systemctl start rabbitmq-server


## MariaDB 的安装

1. `yum install mariadb-server`
2. 登入 mariadb `mysql -uroot -p` , 第一次登陆是 root 用户没有密码,直接进入即可
3. 初始化设置: `mysql_secure_installation` ,可以设置 root 密码,移除匿名账号等等...
4. 设置 root 可远程登录: 
    1. `mysql -uroot -p` 登录
    2. `GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY '123456' WITH GRANT OPTION;` 授权 root 账户,密码 123456
    3. `flush privileges;`
5. 继续后续操作

### Mybatis 连接 MariaDB 中文乱码问题
MariaDB的默认编码是latin1，插入中文会乱码，因此需要将编码改为utf8

1. 首先设置数据库的编码都为 utf8
    1. `SHOW VARIABLES LIKE 'character%';` 查看编码
    2. 修改 /etc/my.cnf.d/client.cnf , 在 `[client]` 里加入 `default-character-set=utf8`
    3. 修改 /etc/my.cnf.d/server.cnf , 在 `[mysqld]` 里加入 `character-set-server=utf8`
    4. `systemctl restart mariadb` 重启生效
    5. 再次查看 `SHOW VARIABLES LIKE 'character%';` 查看编码

2. 建库,建表,表里的 varchar 字段的字符集都用 `utf8`, 排序规则都用 `utf8_unicode_ci`

3. 至此服务端就配置完成了

4. 连接数据配置文件,加上参数

``` yml
      datasource:
        druid:
          url: jdbc:mysql://34.0.7.183:3306/traffic-service?useUnicode=true&characterEncoding=utf8&useSSL=false
```


## DNS 服务安装
1. `yum install bind` 安装完成后服务名为 `named`
2. `vim /etc/named.conf `

``` bash
    options {
            listen-on port 53 { 34.0.7.183; };
            listen-on-v6 port 53 { ::1; };
            directory       "/var/named";
            dump-file       "/var/named/data/cache_dump.db";
            statistics-file "/var/named/data/named_stats.txt";
            memstatistics-file "/var/named/data/named_mem_stats.txt";
            recursing-file  "/var/named/data/named.recursing";
            secroots-file   "/var/named/data/named.secroots";
            allow-query     { any; };
    
            /* 
             - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
             - If you are building a RECURSIVE (caching) DNS server, you need to enable 
               recursion. 
             - If your recursive DNS server has a public IP address, you MUST enable access 
               control to limit queries to your legitimate users. Failing to do so will
               cause your server to become part of large scale DNS amplification 
               attacks. Implementing BCP38 within your network would greatly
               reduce such attack surface 
            */
            recursion yes;
    
            dnssec-enable yes;
            dnssec-validation yes;
    
            /* Path to ISC DLV key */
            bindkeys-file "/etc/named.iscdlv.key";
    
            managed-keys-directory "/var/named/dynamic";
    
            pid-file "/run/named/named.pid";
            session-keyfile "/run/named/session.key";
    };
    
    logging {
            channel default_debug {
                    file "data/named.run";
                    severity dynamic;
            };
    };
    
    zone "." IN {
            type hint;
            file "named.ca";
    };
    
    include "/etc/named.rfc1912.zones";
    include "/etc/named.root.key";
    
```

`listen-on port 53 { 127.0.0.1; };`       # 指定服务监听的端口，建议写本机IP，减少服务器消耗
`allow-query     { any; };`               # 允许哪些客户端访问DNS服务，此处改为“any”，表示任意主机

修改这2项配置即可
`include "/etc/named.rfc1912.zones"; `    # include代表该文件是子配置文件

3. `vim /etc/named.rfc1912.zones ` , 添加一个我们自定义的域名配置,这里我使用的是 `baidu.com`

``` bash
    zone "baidu.com" IN {
            type master;
            file "data/baidu.com.zone";
            allow-update { none; };
    };
```

上述文件默认的目录在 `/var/named/data` 目录下

4. `vim /var/named/data/baidu.com.zone `

配置如下: 注意格式

``` bash
    $TTL 1D
    @       IN SOA         baidu.com. root (
                                            1       ; serial
                                            1D      ; refresh
                                            1H      ; retry
                                            1W      ; expire
                                            0 )     ; minimum
    
    @       IN      NS      ns.baidu.com.
    ns      IN      A       34.0.7.183
    @       IN      A       34.0.7.183
    test    IN      A       34.0.7.183
    liufa   IN      A       34.0.7.227
```

注意第一条记录 `ns.baidu.com.` 的解析必须添加否则会报错,添加之后,再加一条 ns 子域名的解析,直接指向自己即可

这里附上一些配置的解释:

- serial：序列号。可以供从服务器判断何时获取新数据的，这里我设成今天的日期。更新数据文件必须要更新这个序列号，否则从服务器将不更新
- refresh：指定多长时间从服务器要与主服务器进行核对
- retry：如果从服务器试图检查主服务器的序列号时，主服务器没有响应，则经过这个时间后将重新进行检查
- expire：将决定从服务器在没有主服务器的情况下权威地持续提供域数据服务的时间长短
- minimum：高速缓存否定回答的存活时间
- SOA记录：每个区仅有一个SOA记录，该区一直延伸到遇见另一个SOA记录为止。SOA记录包括区的名字，一个技术联系人和各种不同的超时值
- IN记录：使用“IN”，对应的是internet
- A记录：是DNS数据库的核心。一个主机必须为它的每个网络接口得到一条A记录
- NS记录：识别对一个区有权威性的服务器（即所有主服务器和从服务器），并把子域委托给其他机构。
- MX记录：电子邮件系统就是使用MX记录来更有效的路由邮件。
- PTR记录：从IP地址到主机名的反向映射。与A记录一样，必须为每个网络接口有一条PTR记录。

5. `chown root:named baidu.com.zone` 修改权限
6. `systemctl restart named`
