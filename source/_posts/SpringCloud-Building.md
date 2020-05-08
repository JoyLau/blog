---
title: SpringCloud --- 构建开发环境
date: 2017-4-24 14:26:19
cover: //image.joylau.cn/blog/SpringEureka.png
description: 话不多说，想要使用就得创建服务和服务注册中心以及注册发现他们！
categories: [SpringCloud篇]
tags: [SpringBoot,SpringCloud,Eureka]
---

<!-- more -->
![emoji](//image.joylau.cn/blog/SpringEureka.png)

## 来个简单的小例子
2个项目先来测试一下：
- eureka-server
- eureka-service


## eureka-server

### pom 配置

``` xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    	<modelVersion>4.0.0</modelVersion>
    
    	<groupId>cn.joylau.cloud.eureka.server</groupId>
    	<artifactId>eureka-server</artifactId>
    	<version>0.0.1-SNAPSHOT</version>
    	<packaging>jar</packaging>
    
    	<name>eureka-server</name>
    	<description>Demo project for Spring Boot</description>
    
    	<parent>
    		<groupId>org.springframework.boot</groupId>
    		<artifactId>spring-boot-starter-parent</artifactId>
    		<version>1.5.0.RELEASE</version>
    		<relativePath/> <!-- lookup parent from repository -->
    	</parent>
    
    	<properties>
    		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    		<project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    		<java.version>1.8</java.version>
    	</properties>
    
    	<dependencies>
    		<dependency>
    			<groupId>org.springframework.cloud</groupId>
    			<artifactId>spring-cloud-starter-eureka-server</artifactId>
    		</dependency>
    
    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-test</artifactId>
    			<scope>test</scope>
    		</dependency>
    	</dependencies>
    
    	<dependencyManagement>
    		<dependencies>
    			<dependency>
    				<groupId>org.springframework.cloud</groupId>
    				<artifactId>spring-cloud-dependencies</artifactId>
    				<version>Dalston.RELEASE</version>
    				<type>pom</type>
    				<scope>import</scope>
    			</dependency>
    		</dependencies>
    	</dependencyManagement>
    
    	<build>
    		<plugins>
    			<plugin>
    				<groupId>org.springframework.boot</groupId>
    				<artifactId>spring-boot-maven-plugin</artifactId>
    			</plugin>
    		</plugins>
    	</build>
    </project>

```

### application.properties

``` bash
    server.port=8080
    eureka.client.register-with-eureka=false
    eureka.client.fetch-registry=false
    eureka.client.serviceUrl.defaultZone=http://localhost:${server.port}/eureka/

```


### EurekaServerApplication
``` java
    package cn.joylau.cloud.eureka.server;
    
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;
    
    @SpringBootApplication
    @EnableEurekaServer
    public class EurekaServerApplication {
    
    	public static void main(String[] args) {
    		SpringApplication.run(EurekaServerApplication.class, args);
    	}
    }

```


## eureka-service

### pom 配置

``` xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    	<modelVersion>4.0.0</modelVersion>
    
    	<groupId>cn.joylau.cloud.eureka.service</groupId>
    	<artifactId>eureka-service</artifactId>
    	<version>0.0.1-SNAPSHOT</version>
    	<packaging>jar</packaging>
    
    	<name>eureka-service</name>
    	<description>Demo project for Spring Boot</description>
    
    	<parent>
    		<groupId>org.springframework.boot</groupId>
    		<artifactId>spring-boot-starter-parent</artifactId>
    		<version>1.5.0.RELEASE</version>
    		<relativePath/> <!-- lookup parent from repository -->
    	</parent>
    
    	<properties>
    		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    		<project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    		<java.version>1.8</java.version>
    	</properties>
    
    	<dependencies>
    		<dependency>
    			<groupId>org.springframework.cloud</groupId>
    			<artifactId>spring-cloud-starter-eureka</artifactId>
    		</dependency>
    
    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-test</artifactId>
    			<scope>test</scope>
    		</dependency>
    	</dependencies>
    
    	<dependencyManagement>
    		<dependencies>
    			<dependency>
    				<groupId>org.springframework.cloud</groupId>
    				<artifactId>spring-cloud-dependencies</artifactId>
    				<version>Brixton.RELEASE</version>
    				<type>pom</type>
    				<scope>import</scope>
    			</dependency>
    		</dependencies>
    	</dependencyManagement>
    
    	<build>
    		<plugins>
    			<plugin>
    				<groupId>org.springframework.boot</groupId>
    				<artifactId>spring-boot-maven-plugin</artifactId>
    			</plugin>
    		</plugins>
    	</build>
    </project>

```

### application.properties

``` bash
    spring.application.name=eureka-service
    server.port=8888
    eureka.client.serviceUrl.defaultZone=http://localhost:8080/eureka/

```


### EurekaServerApplication
``` java
    package cn.joylau.cloud.eureka.service;
    
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
    
    @EnableDiscoveryClient
    @SpringBootApplication
    public class EurekaServiceApplication {
    
    	public static void main(String[] args) {
    		SpringApplication.run(EurekaServiceApplication.class, args);
    	}
    }

```

### ComputeController
``` java
    package cn.joylau.cloud.eureka.service;
    
    import org.apache.log4j.Logger;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.cloud.client.ServiceInstance;
    import org.springframework.cloud.client.discovery.DiscoveryClient;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RequestMethod;
    import org.springframework.web.bind.annotation.RequestParam;
    import org.springframework.web.bind.annotation.RestController;
    
    /**
     * Created by JoyLau on 4/14/2017.
     * cn.joylau.cloud.eureka.service
     */
    @RestController
    public class ComputeController {
        private final Logger logger = Logger.getLogger(getClass());
        @Autowired
        private DiscoveryClient client;
        @RequestMapping(value = "/add" ,method = RequestMethod.GET)
        public Integer add(@RequestParam Integer a, @RequestParam Integer b) {
            ServiceInstance instance = client.getLocalServiceInstance();
            Integer r = a + b;
            logger.info("/add, host:" + instance.getHost() + ", service_id:" + instance.getServiceId() + ", result:" + r);
            return r;
        }
    }

```


## 配置说明

- `@EnableEurekaServer` ： 开启服务发现
- eureka是一个高可用的组件，它没有后端缓存，每一个实例注册之后需要向注册中心发送心跳（因此可以在内存中完成），在默认情况下eureka server也是一个eureka client ,必须要指定一个 server
- 当client向server注册时，它会提供一些元数据，例如主机和端口，URL，主页等。Eureka server 从每个client实例接收心跳消息。 如果心跳超时，则通常将该实例从注册server中删除
- `@EnableDiscoveryClient` ： 注册一个微服务
- `spring.application.name` ：应用名