---
title: Oracle 里 number 类型对应 JdbcType bean 类型记录
date: 2018-07-29 10:31:44
description: Oracle 里 number 类型对应 JdbcType bean 类型记录
categories: [Java]
tags: [Java]
---
<!-- more -->

| number长度 | Java类型   |
| ---------- | ---------- |
| 1~4        | Short      |
| 5~9        | Integer    |
| 10~18      | Long       |
| 18+        | BigDecimal |



须指定number类型的大小。