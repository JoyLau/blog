---
title: 重剑无锋,大巧不工 SpringBoot --- 整合使用 Elasticsearch
date: 2017-10-23 10:07:04
description: "SpringBoot 整合 Elasticsearch 的使用和 MongoDB 非常的相像，完全可以很快速的上手"
categories: [SpringBoot篇]
tags: [Spring,SpringBoot,Elasticsearch]
---

<!-- more -->

## 开始使用

### 引入依赖
``` xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-elasticsearch</artifactId>
    </dependency>
    <dependency>
        <groupId>net.java.dev.jna</groupId>
        <artifactId>jna</artifactId>
        <version>3.0.9</version>
    </dependency>
```

这里需要注意的是： 
    SpringBoot 的版本和 elasticsearch 的版本问题，在springboot 1.3.5 版本之前支持elasticsearch2.0 以下的版本，springboot1.3.5之后的版本支持elasticsearch5.0以下的版本
    net.java.dev.jna 这个依赖是因为启动后报类不存在，加个jna依赖加上后就好了

### 配置文件

``` yaml
    spring:
      data:
        elasticsearch:
          cluster-name: elasticsearch
          cluster-nodes: localhost:9300
```

这里需要注意的是：
    elasticsearch对外提供的api的端口的是9200，提供各个集群间和客户端通信的是9300
    配置文件里 cluster-nodes 配置项如果不填写的话，springboot应用启动时会自动创建内部的 elasticsearch 客户端，你会发现即是本地没开 elasticsearch 服务也能跑起来
    配置多个集群的话 cluster-nodes 就配置多条信息，用逗号隔开

### 在 SpringBoot 项目中使用
- 主要的一个接口`ElasticsearchRepository<T,ID>`,第一个是要存储的实体类,第二个参数是 ID 类型
- 还有个 `ElasticsearchCrudRepository`，顾名思义就是增删改查
- 自定义一个接口实现上述接口
- 定义实体类
- 自定义实现类可直接注入使用
- 默认的已经存在了增删改查的方法了,可以直接使用
- 想要更多的功能可以在接口中实现更多的自定义

自定义一个 DAO :

``` java
    public interface SongDao extends ElasticsearchRepository<Song,Integer> {
    }
```

定义一个实体类 :

``` java
    @Data
    @NoArgsConstructor
    @Document(indexName = "songdb",type = "song")
    public class Song {
        @Id
        private int id;
    
        private String name;
    
        private String author;
    
        private long time;
    
        private String commentKeyId;
    
        private String mp3URL;
    
        /*歌曲封面地址*/
        private String picURL;
    
        /*歌曲描述*/
        private String describe;
    
        /*专辑*/
        private String album;
    
        /*歌词*/
        private String lyric;
    
        /*mvid*/
        private int mvId;
    }
```

注意：
    @Document注解里面的几个属性，类比mysql的话是这样： 
    index –> DB 
    type –> Table 
    Document –> row 
    @Id注解加上后，在Elasticsearch里相应于该列就是主键了，在查询时就可以直接用主键查询，后面一篇会讲到。其实和mysql非常类似，基本就是一个数据库
    indexName在上述注解中需要小写

使用的话 注入SongDAO ，之后就可以看到相应的方法了
使用起来就是如此简单,感觉使用起来很像MongoDB配置

## 有一些注解的配置
### 有时候使用起来会有一些问题
- 在默认策略下, Java 实体类叫什么名字,生成后的表名就叫什么,但我们可能并不想这样
- 同样的道理,有时属性名和字段也并不想一样的
### 注解解决这些问题
- `@Id` : 标明表的 ID , 自带索引,无需维护
- `@Document` : 解决第一个问题
- `@Field` : 解决第二个问题，默认不加@Field 有一写默认配置，一旦添加了@Filed注解，所有的默认值都不再生效。此外，如果添加了@Filed注解，那么type字段必须指定


入门使用就写到这
