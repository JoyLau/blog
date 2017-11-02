---
title: IDEA 中 SpringBoot 项目热部署
date: 2017-11-1 10:05:13
description: "IDEA 中 SpringBoot 项目热部署"
categories: [SpringBoot篇]
tags: [IDEA,SpringBoot]
---

<!-- more -->

本文转自：http://blog.csdn.net/jsshaojinjie/article/details/64125458

maven dependencies增加

``` xml
    <dependency>  
        <groupId>org.springframework.boot</groupId>  
        <artifactId>spring-boot-devtools</artifactId>  
        <optional>true</optional>  
    </dependency> 
```

project增加

``` xml
    <build>  
        <plugins>  
            <plugin>  
                <groupId>org.springframework.boot</groupId>  
                <artifactId>spring-boot-maven-plugin</artifactId>  
                <configuration>  
                <!--fork :  如果没有该项配置，devtools不会起作用，即应用不会restart -->  
                <fork>true</fork>  
                </configuration>  
            </plugin>  
        </plugins>  
    </build>  
```

idea设置

![image](http://img.blog.csdn.net/20170320144352296?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvanNzaGFvamluamll/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

ctrl+shift+alt+/

![image](http://img.blog.csdn.net/20170320144426734?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvanNzaGFvamluamll/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
![image](http://img.blog.csdn.net/20170320144446687?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvanNzaGFvamluamll/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

重启项目即可。