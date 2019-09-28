---
title: Gradle 升级到 5.x+ 之后遇到的问题记录
date: 2019-09-28 11:59:46
description: 之前项目升级到 Gradle 5.2 版本后,出现了一点问题,现记录并解决如下
categories: [Gradle篇]
tags: [Gradle]
---

<!-- more -->

### lombok 依赖编译报错
在gradle4.7以后对于加入依赖lombok方式发生变化，gradle4.7版本以前，可以直接如下引用：

```groovy
    compile("org.projectlombok:lombok:1.18.2")或者compileOnly("org.projectlombok:lombok:1.18.2")
```

在gradle5.0这种方式会产生警告,在gradle5.0里面会直接报编译错误

有 2 中解决方式:
1. 官方推荐

开发依赖：

```groovy
    annotationProcessor 'org.projectlombok:lombok:1.18.2'

    compileOnly 'org.projectlombok:lombok:1.18.2'               

```

测试依赖:

```groovy
    testAnnotationProcessor 'org.projectlombok:lombok:1.18.2'

    testCompileOnly 'org.projectlombok:lombok:1.18.2'
```

2. gradle-lombok插件方式

```groovy
    repositories {                 
      mavenCentral()          
    }
    
    
    plugins { 
     
       id 'net.ltgt.apt' version '0.10' 
       
    }
    
    dependencies {
      
            compileOnly 'org.projectlombok:lombok:1.18.2'
            
            apt "org.projectlombok:lombok:1.18.2"
    }
```


### log4j 报错
错误信息:
```bash
    Errors occurred while build effective model from /Users/joylau/.gradle/caches/modules-2/files-2.1/log4j/log4j/1.2.16/88efb1b8d3d993fe339e9e2b201c75eed57d4c65/log4j-1.2.16.pom:
    'build.plugins.plugin[io.spring.gradle.dependencymanagement.org.apache.maven.plugins:maven-antrun-plugin].dependencies.dependency.scope' for junit:junit:jar must be one of [compile, runtime, system] but is 'test'. in log4j:log4j:1.2.16

```

这是因为 Log4J 1.2.16 的 pom 中存在一个Bug。1.2.16 已经在 2010 年停止更新了
可以通过声明对 log4j：log4j：1.2.17 的显式依赖
或通过依赖关系管理确保使用 1.2.17 来解决

```groovy
    implementation("log4j:log4j:1.2.17")
```