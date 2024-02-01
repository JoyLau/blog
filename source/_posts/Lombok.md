---
title: Lombok 注解小记
date: 2018-5-15 10:24:24
cover: //s3.joylau.cn:9000/blog/Lombok.png
description: Lombok 一些常用注解记录
categories: [工具类篇]
tags: [Lombok]
---

<!-- more -->


![img](//s3.joylau.cn:9000/blog/Lombok.png)

- val可以将变量申明是final类型。
- @NonNull注解能够为方法或构造函数的参数提供非空检查。
- @Cleanup注解能够自动释放资源。
- @Getter/@Setter注解可以针对类的属性字段自动生成Get/Set方法。
- @ToString注解，为使用该注解的类生成一个toString方法，默认的toString格式为：ClassName(fieldName= fieleValue ,fieldName1=fieleValue)。
- @EqualsAndHashCode注解，为使用该注解的类自动生成equals和hashCode方法。
- @NoArgsConstructor, @RequiredArgsConstructor, @AllArgsConstructor,这几个注解分别为类自动生成了无参构造器、指定参数的构造器和包含所有参数的构造器。
- @Data注解作用比较全，其包含注解的集合 @ToString， @EqualsAndHashCode，所有字段的 @Getter和所有非final字段的 @Setter, @RequiredArgsConstructor。
- @Builder注解提供了一种比较推崇的构建值对象的方式。
- @Synchronized注解类似Java中的Synchronized 关键字，但是可以隐藏同步锁


官网地址： https://www.projectlombok.org/features/all
