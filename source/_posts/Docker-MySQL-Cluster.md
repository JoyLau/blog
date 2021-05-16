---
title: Docker MySQL 最简单的主从搭建
date: 2021-04-12 17:07:05
description: Docker MySQL 最简单的主从搭建
categories: [Docker篇]
tags: [Docker,MySQL]
---

<!-- more -->
### 主：

```yaml
    version: "3"
    services:
      mysql:
        image: mysql:8.0.22
        container_name: mysql
        restart: always
        security_opt:
          - seccomp:unconfined
        ports:
          - 3306:3306
        volumes:
          - ./mysql-data:/var/lib/mysql
          - ./my.cnf:/etc/mysql/my.cnf
        environment:
          - MYSQL_ROOT_PASSWORD=Kaiyuan@2020
          - TZ=Asia/Shanghai
```

my.cnf:

```shell
    [mysqld]
    pid-file = /var/run/mysqld/mysqld.pid
    socket = /var/run/mysqld/mysqld.sock
    datadir = /var/lib/mysql
    secure-file-priv= NULL
    
    # Custom config should go here
    !includedir /etc/mysql/conf.d/
    
    max_connections=1024
    
    sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
    
    server-id=1
```


最主要的配置： server-id=1

### 从：

```yaml
    version: "3"
    services:
      mysql:
        image: mysql:8.0.22
        container_name: mysql-slave-1
        restart: always
        security_opt:
          - seccomp:unconfined
        ports:
          - 3306:3306
        volumes:
          - ./mysql-data:/var/lib/mysql
          - ./my.cnf:/etc/mysql/my.cnf
          - ./init.sql:/docker-entrypoint-initdb.d/init.sql
        environment:
          - MYSQL_ROOT_PASSWORD=Kaiyuan@2020
          - TZ=Asia/Shanghai
```

my.cnf:

```shell
    [mysqld]
    pid-file = /var/run/mysqld/mysqld.pid
    socket = /var/run/mysqld/mysqld.sock
    datadir = /var/lib/mysql
    secure-file-priv= NULL
    
    # Custom config should go here
    !includedir /etc/mysql/conf.d/
    
    max_connections=1024
    
    sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
    
    server-id=2
    super-read-only
```

和主不同的是， server-id=2, super-read-only 开启只读模式

init.sql:

```sql
    change master to master_host='10.55.3.122',master_port=3306,master_user='root',master_password='Kaiyuan@2020';
    reset slave;
    start slave;
```