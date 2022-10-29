---
title: SpringCloud --- OpenApi3 + SpringCloud Gateway 聚合文档 
date: 2021-04-02 08:45:35
description: 记录下 OpenApi3 + SpringCloud Gateway 聚合文档的过程
categories: [SpringCloud篇]
tags: [SpringCloud]
---

<!-- more -->

记录下 OpenApi3 + SpringCloud Gateway 聚合文档的过程

## 组件选型
1. SpringDoc
2. Knife4j
3. SpringCloud Gateway

## 项目配置
在所有的 spring boot 项目中引入 SpringDoc

```xml
   <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-ui</artifactId>
      <version>${springdoc.version}</version>
   </dependency>
```

在 gateway 项目中引入 SpringDoc

```xml
   <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-webflux-ui</artifactId>
      <version>${springdoc.version}</version>
   </dependency>
```

并且需要排除 springdoc-openapi-ui 的依赖


