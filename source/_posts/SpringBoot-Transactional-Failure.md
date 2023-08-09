---
title: SpringBoot --- @Transactional 注解下，事务失效的七种场景
date: 2023-08-09 09:42:27
description: '@Transactional注解下，事务失效的七种场景'
categories: [SpringBoot篇]
tags: [SpringBoot]
---

<!-- more -->

### 背景
@Transactional是一种基于注解管理事务的方式，spring通过动态代理的方式为目标方法实现事务管理的增强。

@Transactional使用起来方便，但也需要注意引起@Transactional失效的场景，本文总结了七种情况，下面进行逐一分析。

## 场景
- 异常被捕获后没有抛出
- 抛出非 **RuntimeException** 异常
- 方法内部直接调用
- 新开启一个线程
- 注解到 **private** 方法上
- 数据库本身不支持 （mysql数据库，必须设置数据库引擎为InnoDB）
- 事务传播属性设置错误

> 转载自 https://mp.weixin.qq.com/s/f9oYSo68ZNkEj9g8cXb9yA
