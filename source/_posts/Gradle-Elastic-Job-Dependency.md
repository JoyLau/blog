---
title: Gradle 构建 elastic-job 项目的奇怪依赖问题
date: 2019-01-14 17:54:39
description: 用 gradle 构建的基于 springboot 的 elastic-job 的项目发现始终连接不上 zookeeper, 一顿研究后,发现事情并不简单.....
categories: [Gradle篇]
tags: [Gradle]
---

<!-- more -->

1. 按照官网的说法, gradle 的配置如下:

``` groovy
        compile ('com.dangdang:elastic-job-lite-core:2.1.5')
    
        compile ('com.dangdang:elastic-job-lite-spring:2.1.5')
```


2. 这样配置后,写好示例代码,发现始终连接不上 zookeeper,抛出以下错误:

``` java
    ***************************
    APPLICATION FAILED TO START
    ***************************
    
    Description:
    
    An attempt was made to call the method org.apache.curator.framework.api.CreateBuilder.creatingParentsIfNeeded()Lorg/apache/curator/framework/api/ProtectACLCreateModePathAndBytesable; but it does not exist. Its class, org.apache.curator.framework.api.CreateBuilder, is available from the following locations:
    
        jar:file:/Users/joylau/.gradle/caches/modules-2/files-2.1/org.apache.curator/curator-framework/4.0.1/3da85d2bda41cb43dc18c089820b67d12ba38826/curator-framework-4.0.1.jar!/org/apache/curator/framework/api/CreateBuilder.class
    
    It was loaded from the following location:
    
        file:/Users/joylau/.gradle/caches/modules-2/files-2.1/org.apache.curator/curator-framework/4.0.1/3da85d2bda41cb43dc18c089820b67d12ba38826/curator-framework-4.0.1.jar
    
    
    Action:
    
    Correct the classpath of your application so that it contains a single, compatible version of org.apache.curator.framework.api.CreateBuilder
```


3. 一开始我以为是搭建的 zookeeper 环境有问题,但是用其他工具可以连接的上

4. 又怀疑是 zookeeper 的版本问题,查看了 `com.dangdang:elastic-job-common-core:2.1.5` , 发现其依赖的 zookeeper 版本是 `org.apache.zookeeper:zookeeper:3.5.3-beta`

5. 于是又用 docker 搭建了个 3.5.3-beta 的版本的 zookeeper 单机版

6. 结果问题依旧.......

7. 中间查找问题花费了很长的时间.....

8. 后来把官方的 demo clone 到本地跑次看看,官方的 demo 仅仅依赖一个包 `com.dangdang:elastic-job-lite-core:2.1.5`

9. 发现这个 demo 没有问题,可以连接的上 zookeeper

10. 对比发现2个项目的依赖版本号不一致

![对比图](http://image.joylau.cn/blog/elastic-job-gradle-dependencies.png)

11. 看到 demo 里依赖的 `org.apache.curator:curator-framework` 和 `org.apache.curator:curator-recipes` 都是 2.10.0, 而我引入的版本却是gradle 上的最新版 4.0.1, 而且也能看到2者的 zookeeper 的版本也不一致,一个是 3.4.6,一个是 3.5.3-beta

12. 问题所在找到了

13. 解决问题

``` groovy
    compile ('com.dangdang:elastic-job-lite-core:2.1.5')
    
    compile ('com.dangdang:elastic-job-lite-spring:2.1.5')

    compile ('org.apache.curator:curator-framework:2.10.0')

    compile ('org.apache.curator:curator-recipes:2.10.0')
```

14. 手动声明版本为 2.10.0

15. 问题解决,但是为什么 gradle 会造成这样的问题? 为什么传递依赖时, gradle 会去找最新的依赖版本? 这些问题我还没搞清楚....

16. 日后搞清楚了,或者有眉目了,再来更新这篇文章.