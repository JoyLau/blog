---
title: 关于通用 Mapper Example 使用记录
date: 2018-2-27 10:29:11
description: 以前经常使用通用的 Mapper 的 Example 来进行单表的复杂查询，已经有很长一段时间没有使用了，自己竟然忘了 Example 的用法，于是就重新复习了一遍，现在做一个记录
categories: [MyBatis篇]
tags: [mybatis]
---

<!-- more -->


## 环境准备
- 项目整合 通用 mapper 和 pagehelper 插件，这部分以前有写过，略
- 需要集成 mybatis 的 generator 插件，方便自动生成 实体类和 mapper 类，还可以生成xml，不过一般我们都不用 xml
- baseMapper 需要继承 ExampleMapper<T> 不过只需要继承 Mapper<T> 就可以了，因为 Mapper<T> 已经继承了 ExampleMapper<T>

## Example  的用法
首先需要说明一点 ，和 Example 使用相同的还有 Condition 类 该类继承自 Example，使用方法和 Example 完全一样，只是为了避免语义有歧义重命名的一个类，这里我们都用 Example 来说明
- 创建 Example : 

``` java 
    Example example = new Example(XXX.class);
```

其中构造方法为生成的 model 实体类，还有 2 个构造方法

``` java 

        /**
         * 带exists参数的构造方法，默认notNull为false，允许为空
         *
         * @param entityClass
         * @param exists      - true时，如果字段不存在就抛出异常，false时，如果不存在就不使用该字段的条件
         */
        public Example(Class<?> entityClass, boolean exists) {
           ...
        }
    
        /**
         * 带exists参数的构造方法
         *
         * @param entityClass
         * @param exists      - true时，如果字段不存在就抛出异常，false时，如果不存在就不使用该字段的条件
         * @param notNull     - true时，如果值为空，就会抛出异常，false时，如果为空就不使用该字段的条件
         */
        public Example(Class<?> entityClass, boolean exists, boolean notNull) {
           ...
        }
```

然后可以对 example 的实体类的单表进行查询了

``` java 
    Example example = new Example(XXX.class);
    example.createCriteria().andGreaterThan("id", 100).andLessThan("id",151);
    example.or().andLessThan("id", 41);
    List<XXX> list = mapper.selectByExample(example);
```

以上查询的条件是，查询 id 大于 100 并且小于 151 或者 id 小于 41 的记录

还可以写成 sql 的方式：

``` java 
    Example example = new Example(XXX.class);
    example.createCriteria().andCondition("id > 100 and id <151 or id < 41");
    
    // andCondition() 方法可以叠加使用，像这样
    example.createCriteria().andCondition("id > 100 and id <151").orCondition("id <41");
    
```

andCondition() 有2中使用方法：
andCondition(String condition) ： 手写条件，例如 “length(name)<5”
andCondition(String condition, Object value) : 手写左边条件，右边用value值,例如 "length(name)=" "5"
orCondition() 也是类似的

example 里有很多 mysql 常用的方法，使用方法和 elasticsearch 的 java api 很类似，这里列举几个

- `Set<String> selectColumns` : 查询的字段
- `Set<String> excludeColumns` ： 排除的查询字段
- `Map<String, EntityColumn> propertyMap` ： 属性和列对应
- andAllEqualTo ： 将此对象的所有字段参数作为相等查询条件，如果字段为 null，则为 is null
- andGreaterThan ： and 条件 大于
- andBetween : and 条件 between
- andEqualTo : 将此对象的不为空的字段参数作为相等查询条件 还有一种有 value 参数的是 = 条件
- andGreaterThanOrEqualTo ： and 条件 》=

还有一些一看就知道意思的

- andIn
- andIsNotNull
- andIsNull
- andLessThan
- andLessThanOrEqualTo
- andNotLike

上面是以 and 条件举例 ，or的条件也是一样的

## 集成分页功能
我们知道 PageHelper.startPage(pageNum, pageSize); 可以对 后面的一个 select 进行分页
那么我们可以对 example 进行一个分页查询的封装

``` java 

    // 在baseMapper 里封装一个接口
    PageInfo selectPageByExample(int pageNum, int pageSize, Object example);
    
    //这样实现上面的接口
    @Override
    public PageInfo selectPageByExample(int pageNum, int pageSize, Object example) {
        PageHelper.startPage(pageNum, pageSize);
        List<T> list = selectByExample(example);
        return new PageInfo<>(list);
    }
    
    //java 8 的lamda 用法
    @Override
    public PageInfo selectPageByExample(int pageNum, int pageSize, Object example) {
        return PageHelper.startPage(pageNum, pageSize).doSelectPageInfo(()->baseMapper.selectByExample(example));
    }
```