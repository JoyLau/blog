---
title: SpringBoot3 RestClient 打印请求和响应日志
date: 2024-05-13 15:52:28
description: "SpringBoot3 RestClient 打印请求和响应日志"
categories: [SpringBoot篇]
tags: [SpringBoot]
---

<!-- more -->

### 引入依赖
RestClient 默认 **requestFactory** 使用的是 **JdkClientHttpRequestFactory**， 没有日志功能
这里需要切换为 **HttpComponentsClientHttpRequestFactory**

```xml
        <!-- 新版 restClient 使用-->
        <dependency>
            <groupId>org.apache.httpcomponents.client5</groupId>
            <artifactId>httpclient5</artifactId>
        </dependency>
```

### 配置类
这里我额外加入了 Base 认证和一个 json 的消息转换器

```java
    @Bean
    public RestClient mqttApiRestClient(ObjectMapper objectMapper) {
        String auth = mqttProperties.getRest().getApiKey() + ":" + mqttProperties.getRest().getSecretKey();
        byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(StandardCharsets.UTF_8));
        String header = "Basic " + new String(encodedAuth);
        HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();
        factory.setConnectTimeout(3000);
        factory.setConnectionRequestTimeout(5000);
        return RestClient.builder()
                .requestFactory(factory)
                .messageConverters(httpMessageConverters -> httpMessageConverters.add(4,
                        new MappingJackson2HttpMessageConverter(objectMapper)))
                .baseUrl(mqttProperties.getRest().getApi())
                .defaultHeader("Authorization", header)
                .build();
    }
```

### 日志配置
```yaml
logging:
  level:
    # restClient 日志打印
    org.apache.hc.client5.http.wire: debug
```