---
title: SpringBoot 内置的日志过滤器， 记录请求的详细信息
date: 2024-10-16 16:20:25
description: SpringBoot 内置的日志过滤器， 记录请求的详细信息
categories: [SpringBoot]
tags: [SpringBoot]
---

通过 **AbstractRequestLoggingFilter** 可以记录请求的详细信息。

<!-- more -->

### 使用
查看源码

注册 `CommonsRequestLoggingFilter` Bean 并配置即可，

日志级别需要设置为 debug 

```properties
logging.level.org.springframework.web.filter.CommonsRequestLoggingFilter=DEBUG
```

