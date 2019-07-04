---
title: Gradle 配置代理
date: 2019-07-04 14:52:04
description: 用 gradle 构建经常失败,主要是国内网络的原因,这时候配置代理,构建过程要轻松许多
categories: [Gradle篇]
tags: [Gradle]
---

<!-- more -->

### 背景
用 gradle 构建经常失败,主要是国内网络的原因,这时候配置 gradle 使用代理,构建过程要轻松许多

### 做法
1.  JVM system properties
例如: 
System.setProperty('http.proxyHost', 'www.somehost.org')

2. 配置 gradle.properties

``` properties
    ## http
    systemProp.http.proxyHost=www.somehost.org
    systemProp.http.proxyPort=8080
    systemProp.http.proxyUser=userid
    systemProp.http.proxyPassword=password
    systemProp.http.nonProxyHosts=*.nonproxyrepos.com|localhost
    
    ## https
    systemProp.https.proxyHost=www.somehost.org
    systemProp.https.proxyPort=8080
    systemProp.https.proxyUser=userid
    systemProp.https.proxyPassword=password
    systemProp.https.nonProxyHosts=*.nonproxyrepos.com|localhost
```