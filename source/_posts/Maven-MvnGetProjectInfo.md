---
title: Maven --- mvn 命令获取 maven 项目的信息
date: 2021-07-05 16:38:20
description: " "
categories: [Maven篇]
tags: [Maven]
---
<!-- more -->

## 使用 Maven 的 exec 插件
有时候我们需要使用 mvn 命令获取 maven 项目的一些信息， 比如版本号， 项目名称，项目描述等，除了解析 pom.xml 文件，还可以使用以下
命令来获取这些信息

```shell
    mvn -q -N -Dexec.executable="echo"  -Dexec.args='${project.description}'  org.codehaus.mojo:exec-maven-plugin:3.0.0:exec
```
