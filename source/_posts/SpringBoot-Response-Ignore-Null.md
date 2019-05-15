---
title: 重剑无锋,大巧不工 SpringBoot --- 序列化返回对象时忽略空或者 null 属性
date: 2019-04-25 15:24:19
description: SpringBoot 序列化返回对象时忽略空或者 null 属性 
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->
### 注解
在类上加入注解
`@JsonInclude(JsonInclude.Include.NON_EMPTY)`

### 解释
`Include.Include.ALWAYS`: 默认
`Include.NON_DEFAULT`: 属性为默认值不序列化
`Include.NON_EMPTY`: 属性为 空（""） 或者为 NULL 都不序列化
`Include.NON_NULL`: 属性为NULL 不序列化
