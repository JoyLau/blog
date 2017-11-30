---
title: 重剑无锋,大巧不工 SpringBoot --- 最新版 SpringBoot 整合 Druid,MyBatis,通用 Mapper,PageHelper的脚手架
date: 2017-11-29 16:54:06
description: "上次自己写这篇文章 已经是今年初了,一年过去了, Spring Boot 项目在不停的更新着,与此同时其他的 stater项目也在不停的更新着,今天就来重新整合下Druid,MyBatis,通用 Mapper,PageHelper,打算在企业级项目中使用"
categories: [SpringBoot篇]
tags: [SpringBoot,Druid,MyBatis,Mapper,PageHelper]
---

<!-- more -->

## 使用说明
上次自己写这篇文章 已经是今年初了,一年过去了, Spring Boot 项目在不停的更新着,与此同时其他的 stater项目也在不停的更新着,今天就来重新整合下Druid,MyBatis,通用 Mapper,PageHelper,打算在企业级项目中使用

当前 SpringBoot 最新的发布版是 1.5.9.RELEASE
昨天还是 1.5.8,今天发现就是1.5.9.RELEASE了
本篇文章搭建的脚手架就是基于 1.5.9.RELEASE

年初我自己搭建这个脚手架使用的时候,那时 Druid,MyBatis,Mapper,PageHelper,这几个开源项目都没有集成 SpringBoot,我自己还是使用 JavaConfig 配置的
现在不一样了,一年过去了,这些项目的作者也开发了对 SpringBoot 支持的 starter 版本

本篇文章就来整合这些开源框架制作一个脚手架

另外是有打算将它应用到企业级项目中的
### 版本
SpringBoot: 1.5.9.RELEASE
SpringBoot-mybatis : 1.3.1
mapper-spring-boot-starter : 1.1.5
pagehelper-spring-boot-starter: 1.2.3
druid-spring-boot-starter: 1.1.5

### pom.xml
``` xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    	<modelVersion>4.0.0</modelVersion>
    
    	<groupId>com.ahtsoft</groupId>
    	<artifactId>ahtsoft-bigdata-web</artifactId>
    	<version>0.0.1-SNAPSHOT</version>
    	<packaging>jar</packaging>
    
    	<name>ahtsoft-bigdata-web</name>
    	<description>ahtsoft bigData Web Project</description>
    
    	<developers>
    		<developer>
    			<name>LiuFa</name>
    			<email>liuf@ahtsoft.com</email>
    		</developer>
    	</developers>
    
    	<parent>
    		<groupId>org.springframework.boot</groupId>
    		<artifactId>spring-boot-starter-parent</artifactId>
    		<version>1.5.9.RELEASE</version>
    		<relativePath/> <!-- lookup parent from repository -->
    	</parent>
    
    	<properties>
    		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    		<project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    		<java.version>1.8</java.version>
    	</properties>
    
    	<dependencies>
    		<!--<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-cache</artifactId>
    		</dependency>-->
    
    		<dependency>
    			<groupId>org.mybatis.spring.boot</groupId>
    			<artifactId>mybatis-spring-boot-starter</artifactId>
    			<version>1.3.1</version>
    		</dependency>
    
            <!--mapper-->
            <dependency>
                <groupId>tk.mybatis</groupId>
                <artifactId>mapper-spring-boot-starter</artifactId>
                <version>1.1.5</version>
            </dependency>
    
            <!--pagehelper-->
            <dependency>
                <groupId>com.github.pagehelper</groupId>
                <artifactId>pagehelper-spring-boot-starter</artifactId>
                <version>1.2.3</version>
            </dependency>
    
            <!--druid-->
            <dependency>
                <groupId>com.alibaba</groupId>
                <artifactId>druid-spring-boot-starter</artifactId>
                <version>1.1.5</version>
            </dependency>
    
            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <scope>runtime</scope>
            </dependency>
    
    		<!--<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-security</artifactId>
    		</dependency>-->
    
    		<!--<dependency>
    			<groupId>org.springframework.session</groupId>
    			<artifactId>spring-session</artifactId>
    		</dependency>-->
    
    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-web</artifactId>
    			<exclusions>
    				<exclusion>
    					<groupId>org.springframework.boot</groupId>
    					<artifactId>spring-boot-starter-tomcat</artifactId>
    				</exclusion>
    			</exclusions>
    		</dependency>
    
    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-undertow</artifactId>
    		</dependency>
    
    		<!--<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-websocket</artifactId>
    		</dependency>-->
    
    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-devtools</artifactId>
    			<scope>runtime</scope>
    		</dependency>
    
    		<dependency>
    			<groupId>org.projectlombok</groupId>
    			<artifactId>lombok</artifactId>
    			<optional>true</optional>
    		</dependency>
    
    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-test</artifactId>
    			<scope>test</scope>
    		</dependency>
    
    		<!--<dependency>
    			<groupId>org.springframework.security</groupId>
    			<artifactId>spring-security-test</artifactId>
    			<scope>test</scope>
    		</dependency>-->
    
    		<dependency>
    			<groupId>com.alibaba</groupId>
    			<artifactId>fastjson</artifactId>
    			<version>1.2.33</version>
    		</dependency>
    
    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-configuration-processor</artifactId>
    			<optional>true</optional>
    		</dependency>
    
    	</dependencies>
    
    	<build>
    		<plugins>
    			<plugin>
    				<groupId>org.springframework.boot</groupId>
    				<artifactId>spring-boot-maven-plugin</artifactId>
    				<configuration>
    					<fork>true</fork>
    				</configuration>
    			</plugin>
    		</plugins>
    	</build>
    
    
    </project>

```

说明:
pom 中除了应用了必要的依赖,还引入了SpringSecurity, 打算做脚手架的安全认证
caffeine cache 打算做 restapi 的 cache 的

使用 devtools 开发时热部署
lombok 简化代码配置
websocket 全双工通信
集群的话 spring-session 做到 session 共享
### application,yml

``` properties
    spring:
      datasource:
        druid:
          url: jdbc:mysql://lfdevelopment.cn:3333/boot-security?useUnicode=true&characterEncoding=utf8&useSSL=false
          username: root
          password: q1pE3gb8+1Q9DkE27wjl0Q1xhiYJJC0w5+TJIZXjEW9fKv9W2h4VOSWOajAVtNXRjaDhtXZlyWN8SAJPqzNFqg==
          driver-class-name: com.mysql.jdbc.Driver
          public-key: MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAK9HqNyD1g+vgwITT4x5EcaWKGJQ7/HCl1C0Uwc8AHPr2y7heJBLGdWtvIKtRKGsn4LCCkyKfVFs87nKKFpJbPECAwEAAQ==
          connection-properties: config.decrypt=true;config.decrypt.key=${spring.datasource.druid.public-key}
          filter:
            config:
              enabled: true
    mybatis:
      type-aliases-package: com.ahtsoft.**.model
      configuration:
        map-underscore-to-camel-case: true
    #    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
    mapper:
      mappers[0]: com.ahtsoft.config.basemapper.BaseMapper
      not-empty: false
      identity: MYSQL
    pagehelper:
      helper-dialect: mysql
      reasonable: true
      supportMethodsArguments: true
      params: count=countSql
    logging:
      level:
        com:
          ahtsoft: debug

```

正常配置了druid 的连接配置,其中使用 ConfigTool 的密码加密功能,提供加密后的密文个公钥,在连接数据库时会自动解密

mybatis 配置了各个 model 的位置,配置开启驼峰命名转换,SQL 语句的打印使用的 springboot 的日志功能,将实现的 StdOutImpl给注释了
配置的分页插件 pagehelper 参数

最后在@ SpringBoot 注解下加入
`@MapperScan(basePackages = "com.ahtsoft.**.mapper")`
用来扫描 mapper自动注入为 bean

项目地址: https://github.com/JoyLau/ahtsoft-bigdata-web.git