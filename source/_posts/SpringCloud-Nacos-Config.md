---
title: SpringCloud --- Nacos ConfigurationProperties 配置类自动刷新简记
date: 2021-11-05 10:20:55
description: SpringCloud Nacos ConfigurationProperties 配置类自动刷新简记
categories: [SpringCloud篇]
tags: [SpringBoot,SpringCloud]
---

<!-- more -->
使用 ```@ConfigurationProperties(prefix = "xxxx")``` 注解配置类

在 Nacos 配置中心里修改相应的配置会自动的刷新属性（配置类上不需要注解 @RefreshScope）

还可以通过发送 POST 请求手动刷新 /actuator/refresh 配置

修改保存后会发现日志打印出如下内容：
```shell
2021-09-29 01:02:22.081 INFO [etc-gateway,,] 2664 --- [xxx_6101] c.a.n.client.config.impl.ClientWorker : [fixed-xxxx_6101] [polling-resp] config changed. dataId=etc-gateway.yaml, group=DEFAULT_GROUP
2021-09-29 01:02:22.081 INFO [etc-gateway,,] 2664 --- [xxx_6101] c.a.n.client.config.impl.ClientWorker : get changedGroupKeys:[etc-gateway.yaml+DEFAULT_GROUP]
2021-09-29 01:02:22.129 INFO [etc-gateway,,] 2664 --- [xxx_6101] c.a.n.client.config.impl.ClientWorker : [fixed-xxx_6101] [data-received] dataId=etc-gateway.yaml, group=DEFAULT_GROUP, tenant=null, md5=5b9beb32de2d18493f8f840ecdabc9d5, content=spring:
application:
name: etc-gateway
profiles:
include: base
cloud:
gateway:
..., type=yaml

2021-09-29 01:02:23.891  INFO [etc-gateway,,] 2664 --- [xxx_6101] o.s.c.e.event.RefreshEventListener       : Refresh keys changed: [swagger.production]

```



这里记录我遇到的坑：
控制台打印：

```shell
2021-09-29 01:06:18.896 INFO [etc-gateway,,] 3640 --- [xxx_6101] c.a.nacos.client.config.impl.CacheData : [fixed-xxx_6101] [notify-context] dataId=etc-gateway.yaml, group=DEFAULT_GROUP, md5=4c20b06be83314e17467d3f41d821094
2021-09-29 01:06:19.293 WARN [etc-gateway,,] 3640 --- [xxx_6101] c.a.c.n.c.NacosPropertySourceBuilder : Ignore the empty nacos configuration and get it based on dataId[null.yaml] & group[DEFAULT_GROUP]
2021-09-29 01:06:19.329 WARN [etc-gateway,,] 3640 --- [xxx_6101] c.a.c.n.c.NacosPropertySourceBuilder : Ignore the empty nacos configuration and get it based on dataId[null-base.yaml] & group[DEFAULT_GROUP]

```


这里说明没有正确读到 application.name
在 bootstrap.yml 配置文件里正确配置

```yaml
spring:
  application:
    name: etc-gateway
```

即可

我这里 bootstrap.yml 配置时多个项目公用的，可以配置环境变量 -Dspring.application.name=etc-gateway