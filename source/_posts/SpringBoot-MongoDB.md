---
title: 重剑无锋,大巧不工 SpringBoot --- 整合使用MongoDB
date: 2017-7-18 12:15:24
cover: //image.joylau.cn/blog/SpringBoot-MongoDB.jpg
description: 我最近实现的一个音乐小站，深爬网易云音乐官网的音乐数据<br>数据的存储和快速读取采用的是redis<br>而爬到的数据想持久化存储下来，对于这种很结构化的数据来说MySQL已经并不适用了<br>使用MongoDB来异步存储，以后可以数据分析使用
categories: [SpringBoot篇]
tags: [Spring,SpringBoot,MongoDB]
---

<!-- more -->

## 前言

### MongoDB 安装
- `yum install mongodb-server  mongodb`
- `systemctl start mongod`
- `whereis mongo`

### MongoDB 配置文件
- 修改 bind_ip为 0.0.0.0 即可外网可访问
- 修改 fork 为 true 即可后台运行
- 修改 auth为 true 即访问连接时需要认证
- 修改 port 修改端口号


## 开始使用

### 引入依赖
``` xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-mongodb</artifactId>
    </dependency>
```

### 配置文件
![mongoDB配置](//image.joylau.cn/blog/springboot-mongodb-config.png)
还有种配置url方式: `spring.data.mongodb.uri=mongodb://name:pass@host:port/db_name`

相比这种方式,我觉得第一种截图的方式要更直观一些


### 在 SpringBoot 项目中使用
- 主要的一个接口`MongoRepository<T,ID>`,第一个是要存储的实体类,第二个参数是 ID 类型
- 自定义一个接口实现上述接口
- 定义实体类
- 自定义实现类可直接注入使用
- 默认的已经存在了增删改查的方法了,可以直接使用
- 想要更多的功能可以在接口中实现更多的自定义
- 下面截图所示:

自定义一个 DAO :
![mongoDB-DAO](//image.joylau.cn/blog/springboot-mongodb-dao.png)

查看如何使用 :
![mongoDB-method](//image.joylau.cn/blog/springboot-mongodb-method.png)
有个 username 忘了配置了,得加上的


使用起来就是如此简单,感觉使用起来很像 mybatis 的 mapper 配置

## 有一些注解的配置
### 有时候使用起来会有一些问题
- 在默认策略下, Java 实体类叫什么名字,生成后的表名就叫什么,但我们可能并不想这样
- 同样的道理,有时属性名和字段也并不想一样的
- 有时一些属性我们也并不想存到 MongoDB
### 注解解决这些问题
- `@Id` : 标明表的 ID , 自带索引,无需维护
- `@Document` : 解决第一个问题
- `@Field` : 解决第二个问题
- `@Transient` : 解决第三个问题
### 此外,还有其他的注解
可能并不常用,在此也说明下
- `@Indexed(unique = true)` : 加在属性上,标明添加唯一索引
- `@CompoundIndex` : 复合索引

## 预览
查看下刚爬的网易云官网的歌曲信息吧
<center> ![歌曲信息](//image.joylau.cn/blog/springboot-mongoDB-preview.gif) <center>