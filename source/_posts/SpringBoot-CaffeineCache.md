---
title: 重剑无锋,大巧不工 SpringBoot --- 推荐使用CaffeineCache
date: 2017-9-19 18:01:43
description: "在做单系统的情况下，我还是比较喜欢使用Google 的 Guava 来做缓存的，结合 SpringBoot 使用非常简单"
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->
## 今天没有图片
在做单系统的情况下，我还是比较喜欢使用Google 的 Guava 来做缓存的，结合 SpringBoot 使用非常简单 ：

``` xml
    <dependency>
        <groupId>com.google.guava</groupId>
        <artifactId>guava</artifactId>
        <version>23.0</version>
    </dependency>
```


再配置 yml ：

``` xml
    spirng:
        cache:
            type: guava
            cache-names: api_cache
            guava:
              spec: maximumSize=300,expireAfterWrite=2m
```

上述配置了一个 缓存名为 api_cache 的缓存 ，最大数量为300，超时时间为2分钟

接下来，在类中使用注解 @CacheConfig(cacheNames = "api_cache") 来配置整个类的配置
@Cacheable() 注解在方法上来 开启方法的注解

使用很透明

今天再次使用时发现guava.spec提示过期了，查了下文档,文档原话是这样说的：

>> @Deprecated
           @DeprecatedConfigurationProperty(
               reason = "Caffeine will supersede the Guava support in Spring Boot 2.0",
               replacement = "spring.cache.caffeine.spec"
           )



原来，在SpringBoot2.0中推荐使用Caffeine，表达式就是spring.cache.caffeine.spec

更改的方法很简单，改下依赖包，换个配置名，又可以愉快的额使用了：

``` xml
    <dependency>
        <groupId>com.github.ben-manes.caffeine</groupId>
        <artifactId>caffeine</artifactId>
    </dependency>
```

更新配置：

``` bash
    spirng:
        cache:
            type: caffeine
            cache-names: api_cache
            caffeine:
              spec: maximumSize=300,expireAfterWrite=2m
```

感觉无缝切换，继续使用吧！！！