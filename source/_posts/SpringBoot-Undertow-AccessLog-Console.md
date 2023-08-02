---
title: SpringBoot Undertow 访问日志重定向到控制台显示
date: 2023-08-02 16:26:30
description: 记录下 SpringBoot Undertow 如何配置访问日志重定向到控制台显示
categories: [SpringBoot]
tags: [SpringBoot]
---

<!-- more -->

### 配置
通常情况下 Spring Boot 使用 Undertow 容器开启访问日志功能，是记录到本地日志文件的， 我这里有个需求是需要记录到控制台上

配置如下：

```yaml
server:
  undertow:
    accesslog:
      enabled: true
      dir: /dev
      prefix: stdout
      suffix:
      rotate: false
```

这样日志会写到 /dev/stdout 上，也就会在服务的控制台打印

改方法适用于 Linux 和 MacOS
