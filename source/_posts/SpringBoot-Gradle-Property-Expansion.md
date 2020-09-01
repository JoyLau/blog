---
title: 重剑无锋,大巧不工 SpringBoot --- 自动注入 Gradle 属性并在自定义 Banner 图中使用
date: 2020-09-01 16:00:53
description: SpringBoot 自动注入 Gradle 属性并在自定义 Banner 图中使用
categories: [SpringBoot篇]
tags: [SpringBoot,Gradle]
---

<!-- more -->
### 背景
有时我们在 gradle 里定义了一些属性, 想在 springboot 的 application 配置文件里使用, 这里介绍这种处理方式, 并且将配置应用于 springboot 的自定义 Banner 图中

### 步骤
1. 配置 build.gradle

添加以下配置

```groovy
    processResources {
        filesMatching('application.yml') {
            expand(project.properties)
        }
    }
```

如果想将 gradle 的配置应用于所有 springboot 配置文件, 则直接使用

```groovy
    processResources {
        expand(project.properties)
    }
```

2. 在 springboot 的配置文件里使用

比如我在 **gradle.properties**  里定义了如下配置:

```properties
    author=JoyLau
    email=2587038142.liu@gmail.com
    projectArtifact=es-doc-office
    projectGroup=cn.joylau.code
    projectVersion=2.0.5
    javaVersion=1.8

```

在 springboot 配置文件里应用:

```yaml
    info:
      app:
        name: ${projectArtifact}
        author: ${author}
        email: ${email}
        version: ${projectVersion}
```

> 需要注意的是: `${}` 是 springboot 里本身使用引入内置变量的方法, 如果使用上述方式, 则原来使用 springboot 内置的方式的话需要加上 `\` 转义, 即使用 `\${}`


经过如上使用, springboot 应用会在编译期将配置文件转化并复制到了项目的 **build/resources/main** 目录下, 如果到该目录下查找配置文件, 则会发现文件里的属性已经被实际的值替换了


### 自定义属性配置到 Banner 图中
很多时候我们会自定义 banner 图, 使用 banner.txt 可以使用 springboot 的内置变量
结合上面的使用方法, 我给出我的使用示例
banner 的生成可以去这个在线网站: [Online Spring Boot Banner Generator](https://devops.datenkollektiv.de/banner.txt/index.html)

#### banner.txt

```text
    ,------.  ,---.           ,------.    ,-----.   ,-----.          ,-----.  ,------. ,------. ,--.  ,-----. ,------.
    |  .---' '   .-'          |  .-.  \  '  .-.  ' '  .--./         '  .-.  ' |  .---' |  .---' |  | '  .--./ |  .---'
    |  `--,  `.  `-.          |  |  \  : |  | |  | |  |             |  | |  | |  `--,  |  `--,  |  | |  |     |  `--,
    |  `---. .-'    |         |  '--'  / '  '-'  ' '  '--'\         '  '-'  ' |  |`    |  |`    |  | '  '--'\ |  `---.
    `------' `-----'          `-------'   `-----'   `-----'          `-----'  `--'     `--'     `--'  `-----' `------'
    
                                   Author        ::    ${info.app.author} (${info.app.email})
                                   Boot Version  ::    ${spring-boot.version}
                                   App  Version  ::    ${info.app.version}


```

#### 最终效果

```text
    ,------.  ,---.           ,------.    ,-----.   ,-----.          ,-----.  ,------. ,------. ,--.  ,-----. ,------.
    |  .---' '   .-'          |  .-.  \  '  .-.  ' '  .--./         '  .-.  ' |  .---' |  .---' |  | '  .--./ |  .---'
    |  `--,  `.  `-.          |  |  \  : |  | |  | |  |             |  | |  | |  `--,  |  `--,  |  | |  |     |  `--,
    |  `---. .-'    |         |  '--'  / '  '-'  ' '  '--'\         '  '-'  ' |  |`    |  |`    |  | '  '--'\ |  `---.
    `------' `-----'          `-------'   `-----'   `-----'          `-----'  `--'     `--'     `--'  `-----' `------'
    
                                   Author        ::    JoyLau (2587038142.liu@gmail.com)
                                   Boot Version  ::    2.1.2.RELEASE
                                   App  Version  ::    2.0.5
    
    2020-09-01 16:15:25.967  INFO 51691 --- [           main] cn.joylau.code.EsDocOfficeApplication    : Starting EsDocOfficeApplication on JoyLaudeMacBook-Pro.local with PID 51691 (/Users/joylau/dev/idea-project/dev-app/es-doc-office/es-doc-office-service/build/classes/java/main started by joylau in /Users/joylau/dev/idea-project/es-doc-office)
    2020-09-01 16:15:25.969  INFO 51691 --- [           main] cn.joylau.code.EsDocOfficeApplication    : The following profiles are active: db,dev
    2020-09-01 16:15:27.130  INFO 51691 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data repositories in DEFAULT mode.
    2020-09-01 16:15:27.231  INFO 51691 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 95ms. Found 3 repository interfaces.
    2020-09-01 16:15:27.643  INFO 51691 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'org.springframework.transaction.annotation.ProxyTransactionManagementConfiguration' of type [org.springframework.transaction.annotation.ProxyTransactionManagementConfiguration$$EnhancerBySpringCGLIB$$54a92264] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)
    2020-09-01 16:15:27.922  WARN 51691 --- [           main] io.undertow.websockets.jsr               : UT026010: Buffer pool was not set on WebSocketDeploymentInfo, the default pool will be used
    2020-09-01 16:15:27.958  INFO 51691 --- [           main] io.undertow.servlet                      : Initializing Spring embedded WebApplicationContext
    2020-09-01 16:15:27.959  INFO 51691 --- [           main] o.s.web.context.ContextLoader            : Root WebApplicationContext: initialization completed in 1933 ms
    2020-09-01 16:15:28.242  INFO 51691 --- [           main] c.a.d.s.b.a.DruidDataSourceAutoConfigure : Init DruidDataSource
    2020-09-01 16:15:28.381  INFO 51691 --- [           main] com.alibaba.druid.pool.DruidDataSource   : {dataSource-1} inited
    2020-09-01 16:15:28.659  INFO 51691 --- [           main] o.elasticsearch.plugins.PluginsService   : no modules loaded
    2020-09-01 16:15:28.660  INFO 51691 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.index.reindex.ReindexPlugin]
    2020-09-01 16:15:28.660  INFO 51691 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.join.ParentJoinPlugin]
    2020-09-01 16:15:28.660  INFO 51691 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.percolator.PercolatorPlugin]
    2020-09-01 16:15:28.660  INFO 51691 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.script.mustache.MustachePlugin]
    2020-09-01 16:15:28.660  INFO 51691 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.transport.Netty4Plugin]
    ..........

    

```