---
title: SpringBoot --- spring-boot-maven-plugin 插件的使用记录
date: 2022-9-21 11:00:39
description: 记录一下 spring-boot-maven-plugin 插件的功能
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->

## 插件引入

```xml
    <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
    </plugin>
```


### 打包可执行 jar 重命名
```xml
   <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
            <!--可执行 jar 重命名-->
            <classifier>exec</classifier>
        </configuration>
    </plugin>
```

### 定义环境变量
```xml
   <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
            <environmentVariables>
                <ENV1>5000</ENV1>
                <ENV2>Some Text</ENV2>
                <ENV3/>
            </environmentVariables>
        </configuration>
    </plugin>
```

### 定义系统变量
```xml
   <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
            <systemPropertyVariables>
                <property1>test</property1>
                <property2>${my.value}</property2>
            </systemPropertyVariables>
        </configuration>
    </plugin>
```

更多使用方法参考 [文档](https://docs.spring.io/spring-boot/docs/2.1.0.RELEASE/maven-plugin/examples/run-system-properties.html)
