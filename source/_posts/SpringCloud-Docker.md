---
title: SpringCloud --- Docker 部署问题记录
date: 2018-12-18 08:45:35
description: 该篇文章记录使用 Docker 部署 SpringCloud 遇到的问题
categories: [SpringCloud篇]
tags: [SpringCloud,Docker]
---

<!-- more -->

### Docker 容器中 IP 的配置
将 spring cloud 项目部署到 docker 容器中后,虽然可以配置容器的端口映射到宿主机的端口
但是在 eureka 界面显示的instance id 是一串随机的字符串,类似于 d97d725bf6ae 这样的
但是,事实上,我们想让他显示出 IP ,这样我们可以直接点击而打开 info 端点信息

修改 3 处配置项:


``` yaml
    eureka:
      client:
        service-url:
          defaultZone: http://34.0.7.183:9368/eureka/
      instance:
        prefer-ip-address: true
        instance-id: ${eureka.instance.ip-address}:${server.port}
        ip-address: 34.0.7.183
```

1. `eureka.instance.prefer-ip-address` 配置为 true , 表示 instance 使用 ip 配置
2. `eureka.instance.prefer-ip-address` 配置当前 instance 的物理 IP
3. `eureka.instance.prefer-instance-id` 界面上的 instance-id 显示为 ip + 端口


### docker-compose 的解决方法
通常情况下,我们使用 springcloud 都会有很多的服务需要部署,就会产生很多的容器,这么多的容器再使用 docker 一个个操作就显得很复杂
这时候需要一个编排工具,于是我们就使用 docker-compose 来部署 springcloud 服务

1. 修改 eureka 的配置

``` yaml
    spring:
      application:
        name: traffic-service-eureka
    eureka:
      instance:
        hostname: ${spring.application.name}    
```

使用 docker-compose 我们放弃使用 ip 来进行容器间的相互通信,继而使用 hostname,这就相当于在 `/etc/hosts` 添加了一条记录

2. 接下来所有的 eureka 的 client 都使用 traffic-service-eureka 这个 hostname 来连接

``` yaml
    eureka:
      client:
        service-url:
          defaultZone: http://traffic-service-eureka:9368/eureka/
```

3. 如果说想在 eureka 的界面上能够直接显示宿主机的 IP 和 连接地址的话,还需要设置

``` yaml
    eureka:
      instance:
        prefer-ip-address: true
        instance-id: ${eureka.instance.ip-address}:${server.port}
        ip-address: 34.0.7.183
```

4. docker-compose 的配置:

``` yaml
        server:
          image: 34.0.7.183:5000/joylau/traffic-service-server:1.2.0
          container_name: traffic-service-server
          ports:
            - 9368:9368
          restart: always
          volumes:
            - /Users/joylau/log/server:/home/liufa/app/server/logs
          environment:
            activeProfile: prod
          hostname: traffic-service-eureka
          healthcheck:
            test: "/bin/netstat -anp | grep 9368"
            interval: 10s
            timeout: 3s
            retries: 1
        admin:
          image: 34.0.7.183:5000/joylau/traffic-service-admin:1.2.0
          container_name: traffic-service-admin
          ports:
            - 9335:9335
          restart: always
          volumes:
            - /Users/joylau/log/admin:/home/liufa/app/admin/logs
          environment:
            activeProfile: prod
          depends_on:
            server:
              condition: service_healthy
          hostname: traffic-service-admin
          links:
            - server:traffic-service-eureka
```

service 模块 links server 模块,再起个别名 traffic-service-eureka ,因为我配置文件里配置的是 traffic-service-eureka,
这样 service 模块就可以通过 server 或者 traffic-service-eureka 来访问 server 了

另外,配置的 hostname,可以进入 容器中查看 `/etc/hosts` 该配置会在 文件中生成一个容器的 ip 和 hostname 的记录


### 多个服务加载顺序问题
详见 : http://blog.joylau.cn/2018/12/19/Docker-Compose-StartOrder/