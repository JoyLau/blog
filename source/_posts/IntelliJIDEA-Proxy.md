---
title: IntelliJ 软件代理报错：You have JVM property https.proxyHost set..
date: 2020-07-20 09:37:26
description: IntelliJ 软件代理报错：You have JVM property https.proxyHost set..
categories: [IntelliJ IDEA篇]
tags: [IntelliJ IDEA]
---

<!-- more -->

### 报错信息

```shell
    You have JVM property https.proxyHost set to '...'.
    This may lead to incorrect behaviour. Proxy should be set in Settings | Proxy
```

这是由于本地开启了科学上网代理服务造成的

### 解决方式

select Help -> Edit Custom VM Options add below:

-Dhttp.proxyHost
-Dhttp.proxyPort
-Dhttps.proxyHost
-Dhttps.proxyPort
-DsocksProxyHost
-DsocksProxyPort