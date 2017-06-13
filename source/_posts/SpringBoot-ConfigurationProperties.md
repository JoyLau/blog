---
title: 重剑无锋,大巧不工 SpringBoot --- 属性注入
date: 2017-6-13 11:34:58
description: "<center><img src='//image.joylau.cn/blog/configuration-properties.png' alt='SpringBoot-Configuration-Properties.png'></center>  <br>尝试一下更复杂的属性注入吧"
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->

## 通常的属性注入

一般情况下我们使用**Spring**或者**SpringMVC**的时候会使用`@Value()`注入

使用**SpringBoot**的时候会使用`@ConfigurationProperties(prefix = "xxxx")`

注入自定义的呢？这样：`@ConfigurationProperties(prefix = "xxx",locations = "classpath:config/xxxx.properties") `


## 更复杂一点的注入


如上图所示我注入了一个`List<String>`

### 拓展

那么同样的方式，是否可以注入Map<String>,String[]....呢？


### 思考

`properties`的文件被读取的时候使用的就是Map,那么我们知道Map是无序了，这样就会导致我们原先要求的一致性可能达不到

### 解决方式
`properties`文件改成采用`yml`文件，或者升级**SpringBoot**的版本，貌似新版本采用的`LinkedHashMap`