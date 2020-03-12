---
title: Docker 容器内 Java 应用发生 OutOfMemoryError 堆内存空间不足时, 容器无法重启应用
date: 2020-03-12 10:34:13
description: 在一次生产环境部署时发现 docker 容器设置了 --restart always, 容器里应用发生 OutOfMemoryError 错误时没有重启容器.
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## 背景
在一次生产环境部署 elasticsearch 节点时 docker 容器设置了 --restart always, 
此时 elasticsearch 的一个节点发生了 java.lang.OutOfMemoryError: Java heap space
容器并没有重启

elasticsearch 已经设置了 -Xms -Xmx

## 解释
JVM堆内存超出xmx限制，并抛java.lang.OutOfMemoryError: Java heap space异常。堆内存爆了之后，JVM和java进程会继续运行，并不会crash

## 解决
当JVM出现 OutOfMemoryError，要让 JVM 自行退出, 这样容器就会触发重启

添加新的 jvm 配置: ExitOnOutOfMemoryError and CrashOnOutOfMemoryError

该配置支持 jdk8u92 版本及其之后的版本

地址: https://www.oracle.com/technetwork/java/javase/8u92-relnotes-2949471.html

oracle 官网的原话: 

New JVM Options added: ExitOnOutOfMemoryError and CrashOnOutOfMemoryError
Two new JVM flags have been added:

ExitOnOutOfMemoryError - When you enable this option, the JVM exits on the first occurrence of an out-of-memory error. It can be used if you prefer restarting an instance of the JVM rather than handling out of memory errors.

CrashOnOutOfMemoryError - If this option is enabled, when an out-of-memory error occurs, the JVM crashes and produces text and binary crash files (if core files are enabled).

ExitOnOutOfMemoryError: 启用此选项时，JVM在第一次出现内存不足错误时退出。如果您希望重新启动JVM实例而不是处理内存不足错误，则可以使用它。
CrashOnOutOfMemoryError: 如果启用此选项，则在发生内存不足错误时，JVM崩溃并生成文本和二进制崩溃文件（如果启用了核心文件）。

加上配置

> ES_JAVA_OPTS = "-XX:+ExitOnOutOfMemoryError"





