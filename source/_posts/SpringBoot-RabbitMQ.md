---
title: 重剑无锋,大巧不工 SpringBoot --- 整合RabbitMQ
date: 2017-6-16 14:58:40
cover: //image.joylau.cn/blog/spring-boot-rabbitMQ.png
description: 本文将整合SpringBoot和RabbitMQ一个DEMO，后面实现更多样的开发
categories: [SpringBoot篇]
tags: [Spring,SpringBoot,RabbitMQ]
---

<!-- more -->

## 前言

### 本文说明

- 使用之前`rabbitMQ`的介绍我就不说了，我认为你已经了解了
- `rabbitMQ`和`activeMQ`的对比区别我也不说了，我认为你已经查过资料了
- `rabbitMQ`的安装，我也不说了，我认为你下载的时候已经看到了官网的安装说明，给一个Windows安装的链接：[http://www.rabbitmq.com/install-windows.html](http://www.rabbitmq.com/install-windows.html)
- `rabbitMQ`web插件的启用，我也不说，我认为你已经会了
- 那我们开始吧



## 入门使用

### 在使用之前先看一下rabbitMQ-client的使用

先引入依赖：
``` xml
    <dependency>
        <groupId>com.rabbitmq</groupId>
        <artifactId>amqp-client</artifactId>
        <version>3.6.0</version>
    </dependency>
```

在看代码：

``` java
    public void product() throws IOException, TimeoutException {
            // 创建连接工厂
            ConnectionFactory factory = new ConnectionFactory();
            //设置RabbitMQ地址
            factory.setHost("localhost");
            factory.setPort(5672);
            factory.setUsername("guest");
            factory.setPassword("guest");
            //创建一个新的连接
            Connection connection = factory.newConnection();
            //创建一个频道
            Channel channel = connection.createChannel();
            //声明一个队列 -- 在RabbitMQ中，队列声明是幂等性的（一个幂等操作的特点是其任意多次执行所产生的影响均与一次执行的影响相同），也就是说，如果不存在，就创建，如果存在，不会对已经存在的队列产生任何影响。
            channel.queueDeclare(QUEUE_NAME, false, false, false, null);
            String message = "Hello World!";
            //发送消息到队列中
            channel.basicPublish("", QUEUE_NAME, null, message.getBytes("UTF-8"));
            System.out.println("P [x] Sent '" + message + "'");
            //关闭频道和连接
            channel.close();
            connection.close();
        }
    
    
        public void consumer() throws IOException, TimeoutException {
            // 创建连接工厂
            ConnectionFactory factory = new ConnectionFactory();
            //设置RabbitMQ地址
            factory.setHost("localhost");
            factory.setPort(5672);
            factory.setUsername("guest");
            factory.setPassword("guest");
            //创建一个新的连接
            Connection connection = factory.newConnection();
            //创建一个频道
            Channel channel = connection.createChannel();
            //声明要关注的队列 -- 在RabbitMQ中，队列声明是幂等性的（一个幂等操作的特点是其任意多次执行所产生的影响均与一次执行的影响相同），也就是说，如果不存在，就创建，如果存在，不会对已经存在的队列产生任何影响。
            channel.queueDeclare(QUEUE_NAME, false, false, false, null);
            System.out.println("C [*] Waiting for messages. To exit press CTRL+C");
            //DefaultConsumer类实现了Consumer接口，通过传入一个频道，告诉服务器我们需要那个频道的消息，如果频道中有消息，就会执行回调函数handleDelivery
            Consumer consumer = new DefaultConsumer(channel) {
                @Override
                public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                    String message = new String(body, "UTF-8");
                    System.out.println("C [x] Received '" + message + "'");
                }
            };
            //自动回复队列应答 -- RabbitMQ中的消息确认机制
            channel.basicConsume(QUEUE_NAME, true, consumer);
        }
```


代码的注释很详细


## SpringBoot中的使用

### 引入依赖

``` xml
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-amqp</artifactId>
        </dependency>
    </dependencies>
```

### 配置文件

``` yml
    spring:
      rabbitmq:
        host: localhost
        port: 5672
        username: guest
        password: guest
      output:
        ansi:
          enabled: always
```

### 生产者
``` java
    @Component
    public class Product {
        @Autowired
        private AmqpTemplate rabbitTemplate;
    
        public void send() {
            String context = "hello " + new Date();
            System.out.println("生产者发送信息 : " + context);
    
            new Queue("hello");
            this.rabbitTemplate.convertAndSend("hello", context);
        }
    }
```

创建消息生产者Product。通过注入AmqpTemplate接口的实例来实现消息的发送，AmqpTemplate接口定义了一套针对AMQP协议的基础操作。在Spring Boot中会根据配置来注入其具体实现。在该生产者，我们会产生一个字符串，并发送到名为hello的队列中

### 消费者
``` java
    @Component
    @RabbitListener(queues = "hello")
    public class Consumer {
        @RabbitHandler
        public void process(String hello) {
            System.out.println("消费者接受信息 : " + hello);
        }
    }
```

创建消息消费者Consumer。通过@RabbitListener注解定义该类对hello队列的监听，并用@RabbitHandler注解来指定对消息的处理方法。所以，该消费者实现了对hello队列的消费，消费操作为输出消息的字符串内容。


### 测试类
``` java
    @RunWith(SpringRunner.class)
    @SpringBootTest
    public class JoylauSpringBootRabbitmqApplicationTests {
    
    	@Autowired
    	private Product product;
    
    	@Test
    	public void test() throws Exception {
    		product.send();
    	}
    
    }
```

### 再来一张图
![示例截图](//image.joylau.cn/blog/spring-boot-rabbitmq-test.png)


## exchange 多个消费者
当Exchange和RoutingKey相同、queue不同时，所有消费者都能消费同样的信息
Exchange和RoutingKey、queue都相同时，消费者中只有一个能消费信息，其他消费者都不能消费该信息。


下面示例的队列名称可以随意写个,启动时 @RabbitListener 的 bindings 会自动使用 key 绑定队列到exchange
``` java
    @RabbitHandler
    @RabbitListener(
            bindings = @QueueBinding(
                    value = @Queue(value = "${spring.application.name}"),
                    exchange = @Exchange(value = "${spring.rabbitmq.template.exchange}"),
                    key = "${spring.rabbitmq.template.routing-key}")
    )
    public void listenerTrafficMessage(Message message){
        System.out.println(message.getClass().getName());
    }
```

## 消息返回队列

需要处理完消息后在将消息返回队列的话需要配置 spring.rabbitmq.listener.simple.acknowledge-mode: manual
之后注解@RabbitListener 到方法上
Channel channel 进行返回

``` java
    @RabbitHandler
    @RabbitListener(
            bindings = @QueueBinding(
                    value = @Queue(value = "${spring.application.name}"),
                    exchange = @Exchange(value = "${spring.rabbitmq.template.exchange}"),
                    key = "${spring.rabbitmq.template.routing-key}")
    )
    public void listenerTrafficMessage(Message message, Channel channel){

        System.out.println(message.getClass().getName());

        try {
            channel.basicNack(message.getMessageProperties().getDeliveryTag(),false,true);
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
```


```yaml
    spring:
      rabbitmq:
        host: 192.168.10.224
        port: 35672
        username: guest
        password: guest
        virtual-host: /
        listener:
          simple:
            acknowledge-mode: manual #设置消费端手动 ack
            concurrency: 1 #消费者最小数量
            max-concurrency: 1 #消费者最大数量
            prefetch: 1 #在单个请求中处理的消息个数，他应该大于等于事务数量(unack的最大数量)
        template:
          exchange: SURVEY_CENTER
          routing-key: trafficCongestionSituationBD
```

在属性配置文件里面开启了ACK确认 所以如果代码没有执行ACK确认 你在RabbitMQ的后台会看到消息会一直留在队列里面未消费掉 只要程序一启动开始接受该队列消息的时候 又会收到

``` java
    // 告诉服务器收到这条消息 已经被我消费了 可以在队列删掉 这样以后就不会再发了
    // 否则消息服务器以为这条消息没处理掉 后续还会在发，true确认所有消费者获得的消息
    channel.basicAck(message.getMessageProperties().getDeliveryTag(),false);
```

丢弃消息

``` java
    //最后一个参数是：是否重回队列
    channel.basicNack(message.getMessageProperties().getDeliveryTag(), false,false);
    //拒绝消息
    //channel.basicReject(message.getMessageProperties().getDeliveryTag(), true);
    //消息被丢失
    //channel.basicReject(message.getMessageProperties().getDeliveryTag(), false);
    //消息被重新发送
    //channel.basicReject(message.getMessageProperties().getDeliveryTag(), true);
    //多条消息被重新发送
    //channel.basicNack(message.getMessageProperties().getDeliveryTag(), true, true);
```
