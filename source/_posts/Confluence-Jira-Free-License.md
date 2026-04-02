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


## License 优化
下载地址 [atlassian-agent.jar(Atlassian Crack Agent v1.3.1)](https://s3.joylau.cn:9000/mdpic/picgo/2026/04/02/atlassian-agent.jar)  

授权码生成方法  
```shell
java -jar atlassian-agent.jar --help

# products
java -jar atlassian-agent.jar -d -m [Email] -n BAT -p [conf or jira] -o http://[serverip-or-domain] -s [serverId]

# plugins
java -jar atlassian-agent.jar -d -m [Email] -n BAT -p [plugin code] -o http://[serverip-or-domain] -s [serverId]
```

比如我这里 `java -jar atlassian-agent.jar -d -m xxxx@gmail.com -n BAT -p conf -o http://192.168.1.34:8090 -s BT8A-4FXC-D261-6XNR`

得到的授权码可以配置到 `confluence.cfg.xml` 文件中  
配置项为 `atlassian.license.message`, 注意格式上面的换行变成空格即可  

然后使用 -javaagent 加载 atlassian-agent.jar 重启 Confluence 服务即可  

示例:  
```yaml
services:
  confluence:
    image: atlassian/confluence
    container_name: confluence
    restart: always
    ports:
      - 8090:8090
      - 8091:8091
    environment:
      - JAVA_TOOL_OPTIONS='-javaagent:/atlassian-agent.jar'
    volumes:
      - ./atlassian-agent.jar:/atlassian-agent.jar
      - ./mysql-connector-java-8.0.29.jar:/opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-8.0.29.jar
      - ./confluence-data:/var/atlassian/application-data/confluence
```