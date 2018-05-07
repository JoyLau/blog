---
title: ELK(Elasticsearch + Logstash + Kibana) 日志分析平台搭建及 SpringBoot 如何实时发送日志存储到 ELK 平台
date: 2018-5-7 17:11:22
description: "Elasticsearch + Logstash + Kibana + SpringBoot 怎么玩"
categories: [大数据篇]
tags: [Elasticsearch,SpringBoot]
---

<!-- more -->

## 说明
1. Elasticsearch， Logstash，Kibana 版本都是5.3.0
2. SpringBoot 集成 ELK，实际上指的就是 SpringBoot 与 Logstash 的整合
3. Elasticsearch 负责数据的存储，Logstash 负责数据的接受和数据的发送，相当于一个中转站，Kibana 负责数据的展示，查询
4. SpringBoot 项目是我们产生日志并且需要存储和分析的项目
5. SpringBoot 我还是使用的默认的 logback 日志系统，当然也可以采用 log4j,不过我还是比较喜欢 logback，性能好，配置少，有颜色

## Elasticsearch 集群搭建
略

## Logstash 安装
1. 官网下载 Logstash
2. 解压
3. 添加配置文件 log.config

``` bash
    input {
        tcp {
            host => "192.168.10.78"
            type => "dev"
            tags => ["spring-boot"]
            port => 4560
            codec => json_lines
        }
    
        tcp {
            host => "192.168.10.78"
            type => "server"
            tags => ["spring-boot"]
            port => 4561
            codec => json_lines
        }
    
            tcp {
            host => "192.168.10.78"
            type => "work_dev"
            tags => ["boot"]
            port => 4568
            codec => json_lines
        }
    }
    
    filter {
    
    }
    
    output {
            if[type] == "work_dev" {
                    elasticsearch {
                            hosts => ["ip:9268"]
                            index => "logstash_%{type}_%{+YYYY-MM}"
                    }
            } else {
                    elasticsearch {
                            hosts => ["http://192.168.10.232:9211"]
                            index => "logstash_%{type}_%{+YYYY-MM}"
                    }
            }
     }

```

总的来说，配置文件里由 input，filter，output，这里我没有特别复杂的需求，filter就没有配置
我这里有三个input，但是都是 tcp 类型的
意思配置了三个input,分别监听192.168.10.78（就是安装logstash的机器）的4560，4561，和4568端口，有数据发送过来的话就进行output处理
这里我配置了3个type,这个type也就是elasticsearch里索引的type，并且该type可作为参数在output里判断进行不同的处理
codec 是的对日志数据进行处理的插件，这里是 json_lines
所以需要安装插件

``` bash
    sh bin/logstash-plugin install logstash-codec-json_lines
```

elasticsearch:hosts es的http地址和端口
index 是创建的索引名
如果要配置索引模板的话，可以添加以下配置
    manage_template => true
    template_name => "template_name"
    template_overwrite => true
    template => "/usr/local/path.json"

配置好了，我们检验下配置文件是否正确

``` bash
    sh /app/logstash-5.3.0/bin/logstash -f /app/logstash-5.3.0/config/log.config -t
```

没有问题的话就可启动了,后台启动的就用 nohup

``` bash
    sh /app/logstash-5.3.0/bin/logstash -f /app/logstash-5.3.0/config/log.config
```

启动成功的话，9600端口可以获取到 logstash 的相关信息

## SpringBoot 集成 Logstash
1. 添加依赖：

``` xml
    <dependency>
        <groupId>net.logstash.logback</groupId>
        <artifactId>logstash-logback-encoder</artifactId>
        <version>5.1</version>
    </dependency>
```

2. 添加配置 logstash 文件
在 resources 下直接添加 logback.xml 文件即可

``` xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE configuration>
    <configuration>
        <appender name="LOGSTASH" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
            <destination>ip:4568</destination>
            <encoder charset="UTF-8" class="net.logstash.logback.encoder.LogstashEncoder" />
        </appender>
        <include resource="org/springframework/boot/logging/logback/base.xml"/>
        <root level="INFO">
            <appender-ref ref="LOGSTASH" />
        </root>
    
    </configuration>
```

这里我是使用的是 SpringBoot 自带的 logback 日志
SpringBoot 默认会读取 resources 目录下的 logback.xml 作为配置文件，别问我怎么知道的（我特地查看了源码：org.springframework.boot.logging.logback.LogbackLoggingSystem，"logback-test.groovy", "logback-test.xml", "logback.groovy", "logback.xml"这些文件检测到都会读取其中的配置的）
配置文件里我只配置了 一个Appender，就是net.logstash.logback.appender.LogstashTcpSocketAppender，用来输出日志到logstash的，并且级别是 INFO
destination 指的就是 logstash 的地址
encoder 就配置LogstashEncoder不要变
再把 SpringBoot默认的配置引入base.xml

好了，SpringBoot 集成 Logstash 完毕

注 ：后来我想用 javaConfig 去配置 SpringBoot和Logstash，不过没有成功，哪位大佬看到这个信息，可以给我留言下怎么配置
xml,也很方便，打包部署后可以作为配置文件修改


那么，这个时候启动项目，elasticsearch里面就会看到有新的索引数据了


## Kibana 安装
1. 其实 Kibana 非必须安装，只是用来统计数据和查询数据的，用来提供一个可视化的界面
2. 下载 Kibana
3. 修改配置文件 kibana.yml
    server.port: 5668
    server.host: "0.0.0.0"
    elasticsearch.url: "http://localhost:9268"
4. 后台启动
5. 访问kibana的地址即可










