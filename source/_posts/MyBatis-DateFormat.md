---
title: Mybatis 前后台时间传参格式化
date: 2018-5-23 17:37:34
description: 好久不用 mybatis 了,今天突然遇到了一个时间参数的格式化问题.....
categories: [MyBatis篇]
tags: [mybatis]
---

<!-- more -->
## 前言
好久不用 mybatis 了,今天突然遇到了一个时间参数的格式化问题.....
mysql 后台取出的时间格式的字段，传到前台变成了时间戳
一下就想到有一个注解进行格式化
可是半天想不到那个注解怎么写的了，于是一顿查

## 记下来
以前经常使用的注解，现在都忘了，得记下来

1. @JsonFormat(pattern="yyyy-MM-dd HH:mm:ss",timezone="GMT+8") ： 后台 Date 类型转时间字符串，注意时区 （后台 -> 前台）
2. @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss") ：前台时间格式参数转为 javabean 的 Date 类型 （前台 -> 后台）
3. @JSONField(name="end_time", format="yyyy-MM-dd hh:mm:ss") ： fastjson 专用，定义json 的 key，还有时间的格式化，也可以分别在 get set 方法上注解