---
title: SpringBoot 整合 Kafka 踩坑记录
date: 2017-11-2 11:31:37
description: "SpringBoot 整合 Kafka 原本想着很简单，按照SpringBoot的原有的套路来就可以了，没想到中间却遇到了许多坑"
categories: [SpringBoot篇]
tags: [Kafka,SpringBoot]
---

<!-- more -->
### 第一个坑
SpringBoot 在1.5版本后就有了 starter， 但是在依赖列表中却没有找到相应的依赖，原因是名字不叫starter，傻傻的我还用JavaConfig 配置了一遍
现在看下整合 starter 之后的是怎么样的吧！

``` xml
    <dependency>
        <groupId>org.springframework.kafka</groupId>
        <artifactId>spring-kafka</artifactId>
    </dependency>
```

上面这个依赖其实就是starter， 不需要些版本，SpringBoot会自己选择版本

yml配置文件

``` xml
    spring
      kafka:
        bootstrap-servers: 192.168.10.192:9092
        consumer:
          group-id: secondary-identification
        producer:
          batch-size: 65536
          buffer-memory: 524288
```

默认只需要 bootstrap-servers 和 group-id 即可

接下来 生产者 和 消费者

``` java
    @Component
    public class MsgProducer {
        @Autowired
        private KafkaTemplate kafkaTemplate;
        public void sendMessage() {
            kafkaTemplate.send("index-vehicle","key","hello,kafka"  + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS")));
        }
    }
```

``` java
    @Component
    public class MsgConsumer {
        @KafkaListener(topics = {"index-vehicle"})
        public void processMessage(String content) {
            System.out.println(content);
        }
    }
```

### 第二个坑
可以发消息，但是SpringBoot始终收不到，我用Kafka自带的工具却可以收到，很气愤，搞了好长时间都没有解决
后来遍访Google和官方文档，终于找到原因了，只要修改下配置文件的一个配置即可：

``` properties
    # The address the socket server listens on. It will get the value returned from 
    # java.net.InetAddress.getCanonicalHostName() if not configured.
    #   FORMAT:
    #     listeners = listener_name://host_name:port
    #   EXAMPLE:
    #     listeners = PLAINTEXT://your.host.name:9092
    listeners=PLAINTEXT://0.0.0.0:9092
```

上面的额这个 listeners，因为我的程序是加了@KafkaListener 来监听消息的，需要开启一个这样的配置项

这项配置项的含义在此也备注下：

>> 监听列表(以逗号分隔 不同的协议(如plaintext,trace,ssl、不同的IP和端口)),hostname如果设置为0.0.0.0则绑定所有的网卡地址；如果hostname为空则绑定默认的网卡。如果没有配置则默认为java.net.InetAddress.getCanonicalHostName()

这2个坑在此记录下

## 一些常用命令在此记录下
zookeeper-server-start.bat ../../config/zookeeper.properties   : 开启自带的zookeeper
kafka-server-start.bat ../../config.properties   ： 开启kafka
kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic myTopic  --from-beginning : 控制台接受指定topic消息
kafka-console-producer.bat --broker-list localhost:9092 --topic myTopic  :   指定topic发送消息

注意的是用命令行创建的producer绑定的主题topic需要用命令行先创建topic，已经创建的就直接发送就好了