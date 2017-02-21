---
title: 重新拾起我曾抛弃的Thymeleaf
date: 2017-2-20 15:31:12
description: "曾经我在搭建Spring Boot项目时对Thymeleaf提起了兴趣，但是在写了几个页面过后我只想说一句MDZZ<img src='http://static.tieba.baidu.com/tb/editor/images/client/image_emoticon6.png' alt='愤怒'></br>但是今天我又重新拾起了Thymeleaf<img src='http://static.tieba.baidu.com/tb/editor/images/client/image_emoticon25.png' alt='滑稽'>"
categories: [模板引擎篇]
tags: [Thymeleaf,Spring,Spring Boot]
---

<!-- more -->
![Thymeleaf](http://olmkayhqc.bkt.clouddn.com/Thymeleaf.png)


## 历史篇

### 曾经交往过
- 说是历史，也就是在去年，但我感觉已经过了很久。去年我在写`SpringBoot`项目的时候，想找一套前端的模板引擎，看到`SpringBoot`官网推荐使用`Thymeleaf`，就用了它
- 在写了几个页面之后，我在项目里写下了这样一段话
![曾经学习的历史记录](http://olmkayhqc.bkt.clouddn.com/thyemeleafhistory.png)

###  没好印象，我甩了她
- 可以看到我放弃了它，选择了我熟悉的 `Freemarker`（不要问我为什么不选择JSP）

##  重逢篇

### 相遇在spring

- ``Spring``一直都是我崇尚和追求的项目，没事都会翻翻`Spring`的文档查阅查阅
- 无意中我发现`Spring`的官方文档，很多都是用`Thymeleaf`渲染的，这使我重新提起了兴趣

## 交往篇

### 决定重新尝试交往
- 我决定重新学习一下

### 深入了解
- `Thymeleaf` 官网: http://www.thymeleaf.org/
- `Thymeleaf`是一个页面模板，类似于`Freemarker`、`Velocity`等，但`Thymeleaf`可以在服务器环境和静态环境下都能正常运行的页面模板，深受前后端分离开发的团队人员的青睐。
- `Thymeleaf`的数据展现全部通过以th:开头的html自定义标签来完成。当运行在服务器环境时将会按规则替换th:对应的地方显示出服务器上的数据，当运行在静态环境时，html会自动过虑th:开头的属性，显示默认的数据，从而达到两者都能正常运行。
- 整合SpringBoot
    ``` bash
                <dependency>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-thymeleaf</artifactId>
                </dependency>
    ```
如此简单
