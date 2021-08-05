---
title: SpringBoot --- 使用动态多数据源来解决 ShardingSphere jdbc 接管 SpringBoot 全部数据源的问题
date: 2021-07-15 16:50:41
description: 使用动态多数据源来解决 ShardingSphere jdbc 接管 SpringBoot 全部数据源的问题
categories: [SpringBoot]
tags: [ShardingSphere,SpringBoot]
---

<!-- more -->

### 说明
Spring Boot 项目使用 ShardingSphere-JDBC，默认情况下会接管配置的全部数据源，这会导致一些问题
比如，所有的 sql 执行都会走 ShardingSphere 的分库或者分别的逻辑判断
最重要的是，ShardingSphere 不支持的 SQL 会直接报错
比如： https://shardingsphere.apache.org/document/current/cn/user-manual/shardingsphere-jdbc/unsupported-items/
还有： https://shardingsphere.apache.org/document/current/cn/features/sharding/use-norms/sql/#%E4%B8%8D%E6%94%AF%E6%8C%81%E7%9A%84sql

```sql
    -- SELECT子句暂不支持使用*号简写及内置的分布式主键生成器
    INSERT INTO tbl_name (col1, col2, …) SELECT * FROM tbl_name WHERE col3 = ?	
    -- SELECT子句暂不支持使用*号简写及内置的分布式主键生成器
    REPLACE INTO tbl_name (col1, col2, …) SELECT * FROM tbl_name WHERE col3 = ?	
    -- 会导致全路由
    SELECT * FROM tbl_name1 UNION SELECT * FROM tbl_name2	UNION
    SELECT * FROM tbl_name1 UNION ALL SELECT * FROM tbl_name2	UNION ALL
    SELECT * FROM tbl_name WHERE to_date(create_time, ‘yyyy-mm-dd’) = ?	
    -- 查询列是函数表达式时,查询列前不能使用表名;若查询表存在别名,则可使用表的别名
    SELECT MAX(tbl_name.col1) FROM tbl_name	
```

这是不能忍的情况

### 解决方案
官方已经给出的解决方案：
[FQA](https://shardingsphere.apache.org/document/current/cn/others/faq/#6-%E5%A6%82%E6%9E%9C%E5%8F%AA%E6%9C%89%E9%83%A8%E5%88%86%E6%95%B0%E6%8D%AE%E5%BA%93%E5%88%86%E5%BA%93%E5%88%86%E8%A1%A8%E6%98%AF%E5%90%A6%E9%9C%80%E8%A6%81%E5%B0%86%E4%B8%8D%E5%88%86%E5%BA%93%E5%88%86%E8%A1%A8%E7%9A%84%E8%A1%A8%E4%B9%9F%E9%85%8D%E7%BD%AE%E5%9C%A8%E5%88%86%E7%89%87%E8%A7%84%E5%88%99%E4%B8%AD)


> 6. 如果只有部分数据库分库分表，是否需要将不分库分表的表也配置在分片规则中？ 
> 回答：
> 
> 是的。因为ShardingSphere是将多个数据源合并为一个统一的逻辑数据源。因此即使不分库分表的部分，不配置分片规则ShardingSphere即无法精确的断定应该路由至哪个数据源。 
> 但是ShardingSphere提供了两种变通的方式，有助于简化配置。
> 
> 方法1：配置default-data-source，凡是在默认数据源中的表可以无需配置在分片规则中，ShardingSphere将在找不到分片数据源的情况下将表路由至默认数据源。
> 
> 方法2：将不参与分库分表的数据源独立于ShardingSphere之外，在应用中使用多个数据源分别处理分片和不分片的情况。
>

方法 1 的配置方式不适合我
我选择了 方法 2
具体做法如下：

### 操作
#### 依赖引入

```xml
    <dependency>
        <groupId>org.apache.shardingsphere</groupId>
        <artifactId>shardingsphere-jdbc-core-spring-boot-starter</artifactId>
        <version>5.0.0-beta</version>
        <exclusions>
            <!-- 版本太低，有安全漏洞：log4j-1.2.17.jar: CVE-2020-9488, CVE-2019-17571 ，排除掉 -->
            <exclusion>
                <artifactId>log4j</artifactId>
                <groupId>log4j</groupId>
            </exclusion>
        </exclusions>
    </dependency>
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>dynamic-datasource-spring-boot-starter</artifactId>
    </dependency>

```

#### 项目配置

```yaml
    spring:
        application:
          name: im
        datasource:
          dynamic:
            primary: im
            strict: false
            datasource:
              im:
                driver-class-name: com.mysql.cj.jdbc.Driver
                url: jdbc:mysql://xxxxxx:xxxx/im?useUnicode=true&characterEncoding=utf-8
                type: com.zaxxer.hikari.HikariDataSource
                username: xxxx
                password: xxxx
        shardingsphere:
          datasource:
            names: sharding-sphere
            sharding-sphere:
              driver-class-name: com.mysql.cj.jdbc.Driver
              jdbc-url: jdbc:mysql://xxxxxx:xxxx/sharding-sphere?useUnicode=true&characterEncoding=utf-8
              type: com.zaxxer.hikari.HikariDataSource
              username: xxxx
              password: xxxx
          rules:
            sharding:
              tables:
                message:
                  actual-data-nodes: sharding-sphere.message_$->{0..1}_$->{2021..2030}${(1..12).collect{t ->t.toString().padLeft(2,'0')}}
                  table-strategy:
                    complex:
                      sharding-columns: conversation_type, timestamp
                      sharding-algorithm-name: message-table-strategy
              sharding-algorithms:
                message-table-strategy:
                  type: MessageComplexKeysShardingAlgorithm
                  props: { }
          props:
            sql-show: true
```

配置了 2 个数据库
`im` 为主库：正常增删改查的数据库
`sharding`-sphere：专为分库分表的使用的数据库

还配置一个分表规则，分表策略为自定义策略 MessageComplexKeysShardingAlgorithm


#### 自定义策略

shardingsphere-jdbc 5.x 的分表策略使用的是 SPI 机制

具体就是在 `resources/META-INF/services` 目录下新增配置文件 `org.apache.shardingsphere.sharding.spi.ShardingAlgorithm`
将 shardingsphere-jdbc 5.x 自带的策略和自定义的策略加入进去

如下

```text
    #
    # Licensed to the Apache Software Foundation (ASF) under one or more
    # contributor license agreements.  See the NOTICE file distributed with
    # this work for additional information regarding copyright ownership.
    # The ASF licenses this file to You under the Apache License, Version 2.0
    # (the "License"); you may not use this file except in compliance with
    # the License.  You may obtain a copy of the License at
    #
    #     http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.
    #
     
    org.apache.shardingsphere.sharding.algorithm.sharding.inline.InlineShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.mod.ModShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.mod.HashModShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.range.VolumeBasedRangeShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.range.BoundaryBasedRangeShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.datetime.AutoIntervalShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.datetime.IntervalShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.classbased.ClassBasedShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.complex.ComplexInlineShardingAlgorithm
    org.apache.shardingsphere.sharding.algorithm.sharding.hint.HintInlineShardingAlgorithm
    
    com.hfky.im.wildfirechat.msgforward.policy.MessageComplexKeysShardingAlgorithm
```

自定义策略如下：

```java
    public class MessageComplexKeysShardingAlgorithm implements ComplexKeysShardingAlgorithm<Comparable<?>> {

        /**
         * 根据type和time分片。
         */
        @Override
        public Collection<String> doSharding(
                Collection<String> collection, ComplexKeysShardingValue<Comparable<?>> shardingValue) {
        }
    
        @Override
        public void init() {
            //
        }
    
        @Override
        public String getType() {
            return "MessageComplexKeysShardingAlgorithm";
        }
    
        @Override
        public Properties getProps() {
            return ComplexKeysShardingAlgorithm.super.getProps();
        }
    
        @Override
        public void setProps(Properties props) {
            ComplexKeysShardingAlgorithm.super.setProps(props);
        }
    }
```

安装规则重写 doSharding  方法即可

#### 动态多数据源配置

```java
    @Configuration
    public class DataSourceConfiguration {
    
        private final DynamicDataSourceProperties properties;
    
        private final Map<String, DataSource> dataSources;
    
        public DataSourceConfiguration(DynamicDataSourceProperties properties, @Lazy Map<String, DataSource> dataSources) {
            this.properties = properties;
            this.dataSources = dataSources;
        }
    
    
        /**
         * 加入 shardingSphere 的数据源。
         */
        @Bean
        public DynamicDataSourceProvider dynamicDataSourceProvider() {
            return new AbstractDataSourceProvider() {
                @Override
                public Map<String, DataSource> loadDataSources() {
                    Map<String, DataSource> dataSourceMap = new HashMap<>();
                    dataSourceMap.put(ShardingSphereDataSource.class.getAnnotation(DS.class).value(),
                            dataSources.get("shardingSphereDataSource"));
                    return dataSourceMap;
                }
            };
        }
    
        /**
         * 设置主数据源。
         */
        @Bean
        @Primary
        public DataSource dataSource() {
            DynamicRoutingDataSource dataSource = new DynamicRoutingDataSource();
            dataSource.setPrimary(properties.getPrimary());
            dataSource.setStrict(properties.getStrict());
            dataSource.setStrategy(properties.getStrategy());
            dataSource.setP6spy(properties.getP6spy());
            dataSource.setSeata(properties.getSeata());
            return dataSource;
        }
    }
```

2 个注解用来切换数据源

```java
    @Target({ElementType.TYPE, ElementType.METHOD})
    @Retention(RetentionPolicy.RUNTIME)
    @Documented
    @DS("im")
    public @interface ImDataSource {
    }


    @Target({ElementType.TYPE, ElementType.METHOD})
    @Retention(RetentionPolicy.RUNTIME)
    @Documented
    @DS("sharding-sphere")
    public @interface ShardingSphereDataSource {
    }
    
```

#### 使用方法
是需要使用数据源的 Mapper 或者 Service 加入 `@ImDataSource` 注解 或者 `@ShardingSphereDataSource` 注解， 不加的话使用的是默认数据源 im
如上配置的话，正常使用用的就是 im 数据库，分库分表使用的就是 sharding-sphere 数据库
