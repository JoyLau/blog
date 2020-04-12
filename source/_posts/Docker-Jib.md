---
title: Docker Jib 插件使用问题记录
date: 2020-04-12 12:52:31
description: 记录 Docker Jib 插件使用问题记录
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### 错误信息

```text
    Failed to execute goal com.google.cloud.tools:jib-maven-plugin:1.1.2:dockerBuild (default-cli) on project xxxxx: Build to Docker daemon failed, perhaps you should use a registry that supports HTTPS so credentials can be sent safely, or set the 'sendCredentialsOverHttp' system property to true
```


### 解决

这是由于 from image 配置的基础镜像需要认证信息

提示你指定 sendCredentialsOverHttp 参数为 true 即可

于是可以在命令行手动执行:

```bash
    mvn compile com.google.cloud.tools:jib-maven-plugin:1.1.2:dockerBuild -DsendCredentialsOverHttp=true
```

注意是 DsendCredentialsOverHttp

每次去手动执行就很烦

在 idea 里配置如下, 以后双击即可构建

![Docker-Jib-SendCredentialsOverHttp](//image.joylau.cn/blog/docker-jib-sendCredentialsOverHttp.png)