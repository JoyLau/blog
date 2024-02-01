---
title: Redis主从复制 --- 实现读写分离
date: 2017-4-27 13:27:05
cover: //s3.joylau.cn:9000/blog/Redis-Master&Slave.jpg
description: " "
categories: [Redis篇]
tags: [redis]
---

<!-- more -->
![Redis-Master&Slave](//s3.joylau.cn:9000/blog/Redis-Master&Slave.jpg)



## 配置
``` bash
    ################################# REPLICATION #################################
    
    # Master-Slave replication. Use slaveof to make a Redis instance a copy of
    # another Redis server. A few things to understand ASAP about Redis replication.
    #
    # 1) Redis replication is asynchronous, but you can configure a master to
    #    stop accepting writes if it appears to be not connected with at least
    #    a given number of slaves.
    # 2) Redis slaves are able to perform a partial resynchronization with the
    #    master if the replication link is lost for a relatively small amount of
    #    time. You may want to configure the replication backlog size (see the next
    #    sections of this file) with a sensible value depending on your needs.
    # 3) Replication is automatic and does not need user intervention. After a
    #    network partition slaves automatically try to reconnect to masters
    #    and resynchronize with them.
    #
    slaveof xx.xx.xx.xx 6379
    
    # If the master is password protected (using the "requirepass" configuration
    # directive below) it is possible to tell the slave to authenticate before
    # starting the replication synchronization process, otherwise the master will
    # refuse the slave request.
    #
    masterauth xx
    
    # When a slave loses its connection with the master, or when the replication
    # is still in progress, the slave can act in two different ways:
    #
    # 1) if slave-serve-stale-data is set to 'yes' (the default) the slave will
    #    still reply to client requests, possibly with out of date data, or the
    #    data set may just be empty if this is the first synchronization.
    #
    # 2) if slave-serve-stale-data is set to 'no' the slave will reply with
    #    an error "SYNC with master in progress" to all the kind of commands
    #    but to INFO and SLAVEOF.
    #
    slave-serve-stale-data yes
    
    # You can configure a slave instance to accept writes or not. Writing against
    # a slave instance may be useful to store some ephemeral data (because data
    # written on a slave will be easily deleted after resync with the master) but
    # may also cause problems if clients are writing to it because of a
    # misconfiguration.
    #
    # Since Redis 2.6 by default slaves are read-only.
    #
    # Note: read only slaves are not designed to be exposed to untrusted clients
    # on the internet. It's just a protection layer against misuse of the instance.
    # Still a read only slave exports by default all the administrative commands
    # such as CONFIG, DEBUG, and so forth. To a limited extent you can improve
    # security of read only slaves using 'rename-command' to shadow all the
    # administrative / dangerous commands.
    slave-read-only no

```

## 参数解释
- `slaveof` ： Slave库配置Master的ip地址和端口号
- `masterauth` ：如果Master配置了密码，那么这里设置密码
- `slave-serve-stale-data` ： 如果Master宕机了，Salve是否继续提供服务
- `slave-read-only` ： Slave 是否是只读模式，默认为是

## 部分配置项解释
``` bash
    daemonize yes #是否以后台进程运行，默认为no 
    pidfile /var/run/redis.pid #如以后台进程运行，则需指定一个pid，默认为/var/run/redis.pid 
    bind 127.0.0.1 #绑定主机IP，默认值为127.0.0.1（注释） 
    port 6379 #监听端口，默认为6379 
    timeout 300 #超时时间，默认为300（秒） 
    loglevel notice #日志记slave-serve-stale-data yes：在master服务器挂掉或者同步失败时，从服务器是否继续提供服务。录等级，有4个可选值，debug，verbose（默认值），notice，warning 
    logfile /var/log/redis.log #日志记录方式，默认值为stdout 
    databases 16 #可用数据库数，默认值为16，默认数据库为0 
    save 900 1 #900秒（15分钟）内至少有1个key被改变 
    save 300 10 #300秒（5分钟）内至少有300个key被改变 
    save 60 10000 #60秒内至少有10000个key被改变 
    rdbcompression yes #存储至本地数据库时是否压缩数据，默认为yes 
    dbfilename dump.rdb #本地数据库文件名，默认值为dump.rdb 
    dir ./ #本地数据库存放路径，默认值为 ./
    
    slaveof 10.0.0.12 6379 #当本机为从服务时，设置主服务的IP及端口（注释） 
    masterauth elain #当本机为从服务时，设置主服务的连接密码（注释） 
    slave-serve-stale-data yes #在master服务器挂掉或者同步失败时，从服务器是否继续提供服务。 
    requirepass elain #连接密码（注释）
    
    maxclients 128 #最大客户端连接数，默认不限制（注释） 
    maxmemory #设置最大内存，达到最大内存设置后，Redis会先尝试清除已到期或即将到期的Key，当此方法处理后，任到达最大内存设置，将无法再进行写入操作。（注释） 
    appendonly no #是否在每次更新操作后进行日志记录，如果不开启，可能会在断电时导致一段时间内的数据丢失。因为redis本身同步数据文件是按上面save条件来同步的，所以有的数据会在一段时间内只存在于内存中。默认值为no 
    appendfilename appendonly.aof #更新日志文件名，默认值为appendonly.aof（注释） 
    appendfsync everysec #更新日志条件，共有3个可选值。no表示等操作系统进行数据缓存同步到磁盘，always表示每次更新操作后手动调用fsync()将数据写到磁盘，everysec表示每秒同步一次（默认值）。
    
    really-use-vm yes 
    vm-enabled yes #是否使用虚拟内存，默认值为no 
    vm-swap-file /tmp/redis.swap #虚拟内存文件路径，默认值为/tmp/redis.swap，不可多个Redis实例共享 
    vm-max-memory 0 #vm大小限制。0：不限制，建议60-80% 可用内存大小。 
    vm-page-size 32 #根据缓存内容大小调整，默认32字节。 
    vm-pages 134217728 #page数。每 8 page，会占用1字节内存。 
    vm-page-size #vm-pages 等于 swap 文件大小 
    vm-max-threads 4 #vm 最大io线程数。注意： 0 标志禁止使用vm 
    hash-max-zipmap-entries 512 
    hash-max-zipmap-value 64
    
    list-max-ziplist-entries 512 
    list-max-ziplist-value 64 
    set-max-intset-entries 512 
    activerehashing yes
```


## 原理

- 如果设置了一个Slave，无论是第一次连接还是重连到Master，它都会发出一个SYNC命令；
- 当Master收到SYNC命令之后，会做两件事：
    a) Master执行BGSAVE，即在后台保存数据到磁盘（rdb快照文件）；
    b) Master同时将新收到的写入和修改数据集的命令存入缓冲区（非查询类）；
- 当Master在后台把数据保存到快照文件完成之后，Master会把这个快照文件传送给Slave，而Slave则把内存清空后，加载该文件到内存中；
- 而Master也会把此前收集到缓冲区中的命令，通过Reids命令协议形式转发给Slave，Slave执行这些命令，实现和Master的同步；
- Master/Slave此后会不断通过异步方式进行命令的同步，达到最终数据的同步一致；
- 需要注意的是Master和Slave之间一旦发生重连都会引发全量同步操作。但在2.8之后版本，也可能是部分同步操作。


部分复制
- 2.8开始，当Master和Slave之间的连接断开之后，他们之间可以采用持续复制处理方式代替采用全量同步。
    Master端为复制流维护一个内存缓冲区（in-memory backlog），记录最近发送的复制流命令；同时，Master和Slave之间都维护一个复制偏移量(replication offset)和当前Master服务器ID（Master run id）。当网络断开，Slave尝试重连时：
    a. 如果MasterID相同（即仍是断网前的Master服务器），并且从断开时到当前时刻的历史命令依然在Master的内存缓冲区中存在，则Master会将缺失的这段时间的所有命令发送给Slave执行，然后复制工作就可以继续执行了；
    b. 否则，依然需要全量复制操作；
- Redis 2.8 的这个部分重同步特性会用到一个新增的 PSYNC 内部命令， 而 Redis 2.8 以前的旧版本只有 SYNC 命令， 不过， 只要从服务器是 Redis 2.8 或以上的版本， 它就会根据主服务器的版本来决定到底是使用 PSYNC 还是 SYNC ：
    如果主服务器是 Redis 2.8 或以上版本，那么从服务器使用 PSYNC 命令来进行同步。
    如果主服务器是 Redis 2.8 之前的版本，那么从服务器使用 SYNC 命令来进行同步。
    
## 同步机制

### 全量同步
>> Redis全量复制一般发生在Slave初始化阶段，这时Slave需要将Master上的所有数据都复制一份。具体步骤如下： 
   　　1）从服务器连接主服务器，发送SYNC命令； 
   　　2）主服务器接收到SYNC命名后，开始执行BGSAVE命令生成RDB文件并使用缓冲区记录此后执行的所有写命令； 
   　　3）主服务器BGSAVE执行完后，向所有从服务器发送快照文件，并在发送期间继续记录被执行的写命令； 
   　　4）从服务器收到快照文件后丢弃所有旧数据，载入收到的快照； 
   　　5）主服务器快照发送完毕后开始向从服务器发送缓冲区中的写命令； 
   　　6）从服务器完成对快照的载入，开始接收命令请求，并执行来自主服务器缓冲区的写命令；

### 增量同步
>> Redis增量复制是指Slave初始化后开始正常工作时主服务器发生的写操作同步到从服务器的过程。 
增量复制的过程主要是主服务器每执行一个写命令就会向从服务器发送相同的写命令，从服务器接收并执行收到的写命令。


## Redis主从同步策略
主从刚刚连接的时候，进行全量同步；全同步结束后，进行增量同步。当然，如果有需要，slave 在任何时候都可以发起全量同步。redis 策略是，无论如何，首先会尝试进行增量同步，如不成功，要求从机进行全量同步。


## 最后
- 参考文章：http://blog.csdn.net/sk199048/article/details/50725369
- 参考文章：http://blog.csdn.net/stubborn_cow/article/details/50442950