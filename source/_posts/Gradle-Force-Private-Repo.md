---
title: Gradle init.gradle 强制重定向至私有仓库
date: 2026-07-21 10:30:00
description: 记录下通过 init.gradle 强制将 Gradle 所有仓库请求重定向至私有 Nexus 仓库的配置方法
categories: [Gradle篇]
tags: [Gradle, Nexus]
---

<!-- more -->

## 背景

公司内网搭建了一套 Nexus 私服，希望所有 Gradle 项目的依赖下载都走私服，不再去公网仓库拉取。

常见做法是在每个项目的 `build.gradle` 里把 `mavenCentral()`、`google()` 这些仓库替换成私服地址。但是并不能全部依赖都从私服下载，有的依赖还是会从 mavenCentral 和 google 下载。

于是想着能不能有个全局配置，统一拦截并重定向所有仓库请求，被我找到一个方案：通过 Gradle 的 `init.gradle` 来实现。

## init.gradle 配置

在 `~/.gradle/init.gradle`中添加如下配置：

```groovy
allprojects {
    buildscript {
        repositories {
            all { ArtifactRepository repo ->
                if (repo instanceof MavenArtifactRepository && !repo.url.toString().startsWith("http://192.168.1.231:6119")) {
                    project.logger.debug "[Gradle重定向] 项目: ${project.name} (buildscript) | 拦截仓库: ${repo.name} | 原地址: ${repo.url} -> 强制重定向至私有仓库"
                    repo.url = "http://192.168.1.231:6119/repository/maven-public/"
                    repo.allowInsecureProtocol = true
                }
            }
        }
    }
    repositories {
        all { ArtifactRepository repo ->
            if (repo instanceof MavenArtifactRepository && !repo.url.toString().startsWith("http://192.168.1.231:6119")) {
                project.logger.debug "[Gradle重定向] 项目: ${project.name} | 拦截仓库: ${repo.name} | 原地址: ${repo.url} -> 强制重定向至私有仓库"
                repo.url = "http://192.168.1.231:6119/repository/maven-public/"
                repo.allowInsecureProtocol = true
            }
        }
    }
}
```

这里需要注意的是：
    - 私服地址 `http://192.168.1.231:6119/repository/maven-public/` 根据自己实际情况替换
    - 这段配置会拦截**所有** Maven 类型的仓库，将 URL 强制改为私服地址
    - `buildscript` 和 `repositories` 两个块都需要配置，分别对应构建脚本依赖和项目依赖
    - `!repo.url.toString().startsWith("http://192.168.1.231:6119")` 这个判断是为了避免对已经是私服的仓库重复处理

## 关键点说明

### 为什么要写两个 repositories 块

Gradle 里有两个地方配置仓库：
    - `buildscript.repositories`：用于 Gradle 插件等构建脚本自身的依赖
    - `repositories`：用于项目代码的依赖

两者是独立的，所以都需要配置重定向。

### `allowInsecureProtocol = true` 的作用

Gradle 7+ 默认不允许使用 HTTP 协议的仓库（要求 HTTPS）。如果私服地址是 HTTP，必须加上这行，否则会报错：

```
Using insecure protocols with repositories, without explicit opt-in, is unsupported.
```

### 如何查看重定向日志

配置中使用的是 `logger.debug` 级别，需要加 `--debug` 参数才能看到日志输出：

```bash
./gradlew build --debug
```

输出类似：

```
[Gradle重定向] 项目: app | 拦截仓库: MavenRepo | 原地址: https://repo1.maven.org/maven2/ -> 强制重定向至私有仓库
```

这样就能确认哪些仓库被拦截并重定向了。

也可以改成 `project.logger.lifecycle "[Gradle重定向] 项目: ${project.name} (buildscript) | 拦截仓库: ${repo.name} | 原地址: ${repo.url} -> 强制重定向至私有仓库"` 级别，这样在正常构建日志中就能看到重定向信息了。

### 只针对特定项目生效

如果不想全局生效，可以把 `init.gradle` 放在项目根目录下，然后通过命令行指定：

```bash
./gradlew build --init-script ./init.gradle
```

## 私服配置建议

Nexus 这边我创建的是一个 `maven-public` group 仓库，代理了以下几个仓库：
    - Maven Central
    - Google
    - Gradle Plugin Portal

这样所有常见依赖都能通过私服拉到。

具体根据实际情况来，如果项目里用了特殊的仓库地址，也需要在 Nexus 里配上对应的代理。
