---
title: 重剑无锋,大巧不工 SpringBoot --- Jackson 关于日期时间的注解
date: 2021-02-18 11:21:06
description: Jackson 关于日期时间的注解
categories: [SpringBoot]
tags: [Jackson,SpringBoot]
---

<!-- more -->

### 说明
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")   : 后端 =>前端的转换
@DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss") ： 前端 => 后端的转换
@JsonDeserialize(using = LocalDateTimeDeserializer.class) ： jackson 反序列化
@JsonSerialize(using = LocalDateTimeSerializer.class)： jackson 序列化

注意：
1. 当 @JsonFormat 和 @JsonDeserialize 或者 @JsonSerialize 同时存在时， @JsonFormat 优先级更高

2. @JsonFormat不仅可以完成后台到前台参数传递的类型转换，还可以实现前台到后台类型转换。

当content-type为application/json时，优先使用@JsonFormat的pattern进行类型转换。而不会使用@DateTimeFormat进行类型转换。