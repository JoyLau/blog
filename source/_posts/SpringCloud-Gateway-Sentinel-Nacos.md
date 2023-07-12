---
title: SpringCloud --- Spring Cloud Gateway 配合 Sentinel 和 Nacos 实现限流规则持久化
date: 2023-07-12 15:47:27
description: Spring Cloud Gateway 配合 Sentinel 和 Nacos 实现限流规则持久化
categories: [SpringCloud篇]
tags: [SpringBoot,SpringCloud]
---

<!-- more -->
Spring Cloud Gateway 配合 Sentinel 实现限流  
在 sentinel dashboard 配置贵州后，重启服务会失效

本篇介绍如何持久化

### 引入依赖
```xml
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>

        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-alibaba-sentinel-gateway</artifactId>
        </dependency>

        <dependency>
            <groupId>com.alibaba.csp</groupId>
            <artifactId>sentinel-datasource-nacos</artifactId>
        </dependency>
```

### 配置服务
```yaml
spring:
  cloud:
    sentinel:
      filter:
        enabled: false
      scg:
        # 请求被 ban 的响应
        fallback:
          response-status: 429
          response-body: 操作频繁，您已被限流，请稍后重试
          mode: "response"
          content-type: "text/plain; charset=utf-8"
      datasource:
        # 接口分组配置
        gw-api-group:
          nacos:
            server-addr: ${nacos.server-addr}
            username: ${spring.cloud.nacos.username}
            password: ${spring.cloud.nacos.password}
            namespace: sentinel
            group-id: DEFAULT_GROUP
            data-id: gw-api-group-rules
            rule-type: gw-api-group
        # 接口限流配置
        gw-rule:
          nacos:
            server-addr: ${nacos.server-addr}
            username: ${spring.cloud.nacos.username}
            password: ${spring.cloud.nacos.password}
            namespace: sentinel
            group-id: DEFAULT_GROUP
            data-id: gw_flow-rules
            rule-type: gw_flow
      eager: true
```

### 创建配置文件
在 Nacos 上新建命名空间 sentinel，  
再分别新建配置文件 **gw-api-group-rules** 和 **gw_flow-rules**

分别配置如下：

gw-api-group-rules:

```json
[
  {
    "apiName": "cipher_group",
    "predicateItems": [
      {
        "pattern": "/im-wildfirechat/support/cipher",
        "matchStrategy": 0
      }
    ]
  }
]
```

gw_flow-rules:

```json
[
    {
    "resource": "cipher_group",
    "resourceMode": 1,
    "grade": 1,
    "count": 2,
    "intervalSec": 60,
    "controlBehavior": 0,
    "burst": 0,
    "maxQueueingTimeoutMs": 500,
    "paramItem": {
        "parseStrategy": 1,
        "fieldName": null,
        "pattern": null,
        "matchStrategy": 0
        }
    }
]
```

保存

配置文件的配置项参考官方文档: https://sentinelguard.io/zh-cn/docs/api-gateway-flow-control.html

或者参考 代码类 `com.alibaba.csp.sentinel.adapter.gateway.common.rule.GatewayFlowRule` 和 `com.alibaba.csp.sentinel.adapter.gateway.common.api.ApiDefinition`

具有源码可查看 `com.alibaba.cloud.sentinel.datasource.RuleType`

### 验证
启动服务
1. 查看 sentinel dashboard 的配置
2. 调用接口，看是否返回被 ban 信息

![api-group](http://image.joylau.cn/blog/spring-cloud-gateway-sentinel-nacos-api-group.png)
![aip=rule](http://image.joylau.cn/blog/spring-cloud-gateway-sentinel-nacos-rule.png)