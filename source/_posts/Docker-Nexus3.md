---
title: Docker 安装的 Maven 私服 Nexus3 因磁盘爆满而导致的无法启动的问题解决及忘记 admin 用户密码的解决方式
date: 2020-12-08 17:07:05
description: Docker 安装的 Maven 私服 Nexus3 因磁盘爆满而导致的无法启动的问题解决及忘记 admin 用户密码的解决方式
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## Maven 私服 Nexus3 因磁盘爆满而导致的无法启动的问题
### 背景
同事在 Nexus3 私服的宿主机上部署了一个服务, 结果因为网络问题导致服务打印大量的日志信息, 将宿主机的磁盘撑爆了,经过一系列排除, 删除了大日志文件
重启 Nexus3 容器,发现无法启动了, 报错如下:

```bash 
    com.orientechnologies.orient.core.exception.OStorageException: Cannot open local storage '/nexus-data/db/config' with mode=rw
            DB name="config"
            at com.orientechnologies.orient.core.storage.impl.local.OAbstractPaginatedStorage.open(OAbstractPaginatedStorage.java:323)
            at com.orientechnologies.orient.core.db.document.ODatabaseDocumentTx.open(ODatabaseDocumentTx.java:259)
            at org.sonatype.nexus.orient.DatabaseManagerSupport.connect(DatabaseManagerSupport.java:178)
            at org.sonatype.nexus.orient.DatabaseManagerSupport.createInstance(DatabaseManagerSupport.java:312)
            at java.util.concurrent.ConcurrentHashMap.computeIfAbsent(ConcurrentHashMap.java:1660)
            at org.sonatype.nexus.orient.DatabaseManagerSupport.instance(DatabaseManagerSupport.java:289)
            at java.util.stream.ForEachOps$ForEachOp$OfRef.accept(ForEachOps.java:183)
            at java.util.Spliterators$ArraySpliterator.forEachRemaining(Spliterators.java:948)
            at java.util.stream.AbstractPipeline.copyInto(AbstractPipeline.java:482)
            at java.util.stream.ForEachOps$ForEachTask.compute(ForEachOps.java:290)
            at java.util.concurrent.CountedCompleter.exec(CountedCompleter.java:731)
            at java.util.concurrent.ForkJoinTask.doExec(ForkJoinTask.java:289)
            at java.util.concurrent.ForkJoinPool$WorkQueue.runTask(ForkJoinPool.java:1056)
            at java.util.concurrent.ForkJoinPool.runWorker(ForkJoinPool.java:1692)
            at java.util.concurrent.ForkJoinWorkerThread.run(ForkJoinWorkerThread.java:175)
    Caused by: java.lang.NullPointerException: null
            at com.orientechnologies.orient.core.storage.impl.local.paginated.wal.ODiskWriteAheadLog.cutTill(ODiskWriteAheadLog.java:919)
            at com.orientechnologies.orient.core.storage.impl.local.OAbstractPaginatedStorage.makeFullCheckpoint(OAbstractPaginatedStorage.java:3706)
            at com.orientechnologies.orient.core.storage.impl.local.OAbstractPaginatedStorage.recoverIfNeeded(OAbstractPaginatedStorage.java:3937)
            at com.orientechnologies.orient.core.storage.impl.local.OAbstractPaginatedStorage.open(OAbstractPaginatedStorage.java:288)
            ... 14 common frames omitted
```

### 解决
1. 进入宿主机存放 Nexus3 数据目录下

先对该目录分配用户和用户组:

```shell 
    chown -R 200 /home/transport/maven-repos-data
```

分别删除 db/config 目录下和 db/component 目录下的所有的 **.wal** 文件 

```shell 
    cd /home/transport/maven-repos-data/db/config
    
    rm -rf *.wal
    
    cd /home/transport/maven-repos-data/db/component
    
    rm -rf *.wal
```

2. 找到容器中的 **nexus-orient-console.jar** jar 包

```bash 
    find / -name nexus-orient-console.jar
```

进入上述目录, 我这里是: _/var/lib/docker/overlay2/3b9c8d7685a03dcbb9ee69c33cd8fd9b487d980731596da27e7639854c0bb6e1/diff/opt/sonatype/nexus/lib/support_

执行 ```java -jar nexus-orient-console.jar``` , 来连接数据库

```shell 
    connect plocal:/home/transport/maven-repos-data/db/component admin admin
```

执行下列命令进行修复, 修复完成并退出:

```bash 
    rebuild index *
    
    repair database --fix-links
    
    disconnect
    
    exit
```

3. 数据目录重新授权

```bash
    chmod 777 -R /home/transport/maven-repos-data/db
```

4. 重启容器

## Maven 私服 Nexus3 忘记 admin 用户密码的解决

如上述步骤描述的, 运行 **nexus-orient-console.jar** 

进入 security 数据库:

```bash
    connect plocal:/home/transport/maven-repos-data/db/security admin admin
```

将 admin 用户密码重置为 admin123

```bash
    update user SET password="$shiro1$SHA-512$1024$NE+wqQq/TmjZMvfI7ENh/g==$V4yPw8T64UQ6GfJfxYq2hLsVrBY8D1v+bktfOxGdt4b/9BthpWPNUy/CBk6V9iA0nHpzYzJFWO8v/tZFtES8CA==" UPSERT WHERE id="admin"
```

数据目录重新授权

```bash
    chmod 777 -R /home/transport/maven-repos-data/db
```

