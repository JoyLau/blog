---
title: SpringCloud --- Feign 单独为某个接口提供超时配置
date: 2021-04-02 08:45:35
description: Feign 单独为某个接口提供超时配置
categories: [SpringCloud篇]
tags: [SpringCloud,Feign]
---

<!-- more -->

### 配置
1. 将原先的接口提取出来，单独写一份
   @FeignClient(value = "etc-exchange", contextId = "etc-exchange-2", fallback = PsamRemoteServiceFallback2.class)
   重新声明一个 contextId

2. 添加配置项

```yaml
    feign:
      client:
        config:
          etc-exchange-2:
            connect-timeout: 3000
            read-timeout: 3000
```
