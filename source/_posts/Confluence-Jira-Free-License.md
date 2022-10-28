---
title: Confluence 和 Jira 免费 License 申请
date: 2022-07-20 09:06:44
description: 本文记录 Atlassian 旗下的 Confluence 和 Jira 免费 License 申请
categories: [Confluence篇]
tags: [Confluence]
---

<!-- more -->

## 背景
记录一下 Atlassian 旗下的 Confluence 和 Jira 免费 License 申请

## 服务搭建

docker-compose.yml

```yaml
    version: "3"
    services:
      confluence:
        image: atlassian/confluence
        container_name: confluence
        restart: always
        ports:
          - 8090:8090
          - 8091:8091
        volumes:
          - ./confluence-data:/var/atlassian/application-data/confluence
      mysql:
        image: mysql:8.0.22
        container_name: mysql
        security_opt:
          - seccomp:unconfined
        ports:
          - 6101:3306
        restart: always
        volumes:
          - ./mysql-data:/var/lib/mysql
          - ./my.cnf:/etc/mysql/my.cnf
        environment:
          - MYSQL_ROOT_PASSWORD=Kaiyuan@2020
          - TZ=Asia/Shanghai
      jira:
        image: atlassian/jira-software
        container_name: jira
        restart: always
        ports:
          - 8080:8080
        volumes:
          - ./jira-data:/var/atlassian/application-data/jira
```

my.cnf

``` editorconfig
    [mysqld]
    pid-file        = /var/run/mysqld/mysqld.pid
    socket          = /var/run/mysqld/mysqld.sock
    datadir         = /var/lib/mysql
    secure-file-priv= NULL
    
    # Custom config should go here
    !includedir /etc/mysql/conf.d/
    max_connections=1024
    
    sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
    transaction-isolation=READ-COMMITTED
```

## License 申请
到 [Atlassian](https://my.atlassian.com/license/evaluation) 的网站
点击   **New Trial License** 申请新的 License  
选择   **Confluence**  再选择 **Confluence (Data Center)**
填入 Server ID 即可申请免费的一个月的 License 
一个月到期后再次申请即可