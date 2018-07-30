---
title: NamedParameterJdbcTemplate 使用具名参数记录
date: 2018-07-30 09:18:05
description: 最近维护了一个比较老的项目，操作数据库直接用的 Spring 的 JdbcTemplate.....
categories: [Spring]
tags: [Spring]
---
<!-- more -->

### 背景
最近维护了一个比较老的项目，操作数据库直接用的 Spring 的 JdbcTemplate，有很多地方我们传入的参数都是不确定的
简单的还好，复杂的 sql 语句在代码里用字符串拼接起来简直不能忍，
又不想对原来的项目有什么大的改动，就想这能不能在现在的基础上优化一下
还好有 NamedParameterJdbcTemplate

### 解释
具名参数: SQL 按名称(以冒号开头)而不是按位置进行指定. 具名参数更易于维护, 也提升了可读性. 具名参数由框架类在运行时用占位符取代
具名参数只在 NamedParameterJdbcTemplate 中得到支持。NamedParameterJdbcTemplate可以使用全部jdbcTemplate方法

### 初始化
1. 该类位于 `org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate`
2. 有2个构造方法，参数分别是 DataSource 和 JdbcOperations

``` java
    /**
     * Create a new NamedParameterJdbcTemplate for the given {@link DataSource}.
     * <p>Creates a classic Spring {@link org.springframework.jdbc.core.JdbcTemplate} and wraps it.
     * @param dataSource the JDBC DataSource to access
     */
    public NamedParameterJdbcTemplate(DataSource dataSource) {
        Assert.notNull(dataSource, "DataSource must not be null");
        this.classicJdbcTemplate = new JdbcTemplate(dataSource);
    }

    /**
     * Create a new NamedParameterJdbcTemplate for the given classic
     * Spring {@link org.springframework.jdbc.core.JdbcTemplate}.
     * @param classicJdbcTemplate the classic Spring JdbcTemplate to wrap
     */
    public NamedParameterJdbcTemplate(JdbcOperations classicJdbcTemplate) {
        Assert.notNull(classicJdbcTemplate, "JdbcTemplate must not be null");
        this.classicJdbcTemplate = classicJdbcTemplate;
    }
```

3. 实例化 bean 只要将 dataSource 或者 JdbcTemplate 传入到构造参数即可

``` xml
    <bean id="namedParameterJdbcTemplate"
          class="org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate">
        <constructor-arg ref="dataSource"/>
    </bean>
```

### 使用
1. 注入 namedParameterJdbcTemplate


### 参数的传入
namedParameterJdbcTemplate 参数传入有 2 中方法：
1. `Map<String, ?> paramMap` 我们熟知的 map
2. `SqlParameterSource paramSource`
    该接口默认的实现有三个类：
    
    `MapSqlParameterSource` 实现非常简单，只是封装了java.util.Map；
    当 Map<String, ?> paramMap 用吧 或者 new MapSqlParameterSource(paramMap) 参数为 map
    
    `BeanPropertySqlParameterSource` 封装了一个JavaBean对象，通过JavaBean对象属性来决定命名参数的值。
     new BeanPropertySqlParameterSource(dto) new 出一个 BeanPropertySqlParameterSource 对象，构造方法传入实体类即可，绝大部分情况下我们都使用这种方式
    
    `EmptySqlParameterSource` 一个空的SqlParameterSource ，常用来占位使用
     没用过

### 数据返回
1. 返回 Map
2. 返回 RowMapper 包装好的实体类，该类有2中实现
    SingleColumnRowMapper ，sql结果为一个单列的数据，如List<String> , List<Integer>,String,Integer等
    
    BeanPropertyRowMapper， sql结果匹配到对象 List< XxxVO> , XxxVO

### 示例

``` java 
    KnowledgeInfo info = new KnowledgeInfo();
    info.setAuditState("1");
    List<KnowledgeInfo> infos = namedParameterJdbcTemplate.query(
            sql,
            new BeanPropertySqlParameterSource(info),
            new BeanPropertyRowMapper<>(KnowledgeInfo.class)
    );
```

注意： sql 语句中的参数使用 `:参数名` 进行占位
    
