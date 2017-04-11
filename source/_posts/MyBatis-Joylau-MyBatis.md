---
title: JoyLau-MyBatis 使用说明
date: 2017-4-6 17:15:51
description: 整合自己在项目中使用的通用Mapper方法，加上自己的封装，现将说明文档书写如下：
categories: [MyBatis篇]
tags: [mybatis]
---

<!-- more -->


## 关于joylau-mybatis的说明
- 该项目来源自  https://github.com/abel533/Mapper  详细信息和源代码可fork查看
- 我封装之后项目地址  https://github.com/JoyLau/joylau-mybatis
- 我自己整合通用Mapper，分页，以及排序功能，使用起来无缝结合，丝般顺滑
- 我对其封装了所有的通用mapper，并整合本项目添加了自己的方法，详细请查看下文或者在线查看api文档： http://api.joylau.cn/
- 文档你主要需要查看function的类注释
- 下面我来逐一介绍：

### BaseController
继承FunctionController，目前有2个抽象方法，getSession()和getContextPath()，一看就知道是干嘛的，不多说。想要扩展很简单，继续写自己的方法即可


### BaseMapper
- 集成了MySQL所使用的绝大部分通用Mapper，包括BaseMapper，ExampleMapper，RowBoundsMapper，MySqlMapper，IdsMapper...等等，详细可查看API文档，或者下载源码查看
- 所有的单表及简单的多表操作都在这里面啦，基本上你是不需要扩展啦，好不好用，敲起mapper再点一下你就知道了

### BaseService
- 得益于Spring项目的强大支持，在Spring4.x后，支持泛型注入，这使得我们封装的更加简单了
- 现在，不必再调用到Mapper层，现在在Service层就可以完美使用，封装了3个插入方法，4个更新方法，5个删除方法，13个查询方法
- 内容涵盖了单条记录CRUD；根据ID或者属性或者条件CRUD；批量删除，插入；分页查询
- 说下分页查询怎么使用：调用selectPage可以进行单表分页查询，调用selectPageByExample可以进行条件分页查询

### BaseServiceImpl
- 继承的FunctionServiceImpl已经实现了上述所有的通用CURD方法
- 在继承的FunctionServiceImpl类里我提供了获取mapper的方法，由此方法，可以进行很方便的扩展，你懂得~~

### BaseModel
- 添加每个实体都会用到的id属性
- 添加了createTime和updateTime属性，虽然在业务上可能没有什么用处，但是对于开发和运维的作用相当大，谁用谁知道

## 我的接口解释

``` java

    /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 保存一个实体，null的属性也会保存，不会使用数据库默认值
         */
        int insert(T model);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 保存一个实体，null的属性不会保存，会使用数据库默认值
         */
        int insertSelective(T model);
    
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 批量插入，支持批量插入的数据库可以使用，另外该接口限制实体包含`id`属性并且必须为自增列
         */
        int insertList(List<T> list);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据主键更新实体全部字段，null值会被更新
         */
        int updateByPrimaryKey(T model);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据主键更新属性不为null的值
         */
        int updateByPrimaryKeySelective(T model);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据Example条件更新实体`model`包含的全部属性，null值会被更新
         */
        int updateByExample(T model, Object example);
    
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据Example条件更新实体`model`包含的不是null的属性值
         */
        int updateByExampleSelective(T model, Object example);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据实体属性作为条件进行删除，查询条件使用等号
         */
        int delete(T model);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据实体id删除
         */
        int deleteById(int id);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据Example条件删除数据
         */
        int deleteByExample(Object example);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据主键字符串进行删除，类中只有存在一个带有@Id注解的字段
         *
         * @param ids 如 "1,2,3,4"
         */
        int deleteByIds(String ids);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据主键字段进行删除，方法参数必须包含完整的主键属性
         */
        int deleteByPrimaryKey(Object key);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据实体中的属性值进行查询，查询条件使用等号
         */
        List<T> select(T model);
    
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据实体中的id查询实体
         */
        T selectById(int id);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 查询全部结果
         */
        List<T> selectAll();
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据Example条件进行查询
         */
        List<T> selectByExample(Object example);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据example条件和RowBounds进行分页查询
         */
        List<T> selectByExampleAndRowBounds(Object example, RowBounds rowBounds);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据主键字符串进行查询，类中只有存在一个带有@Id注解的字段
         *
         * @param ids 如 "1,2,3,4"
         */
        List<T> selectByIds(String ids);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据主键字段进行查询，方法参数必须包含完整的主键属性，查询条件使用等号
         */
        T selectByPrimaryKey(Object key);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据实体中的属性查询总数，查询条件使用等号
         */
        int selectCount(T model);
    
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据Example条件进行查询总数
         */
        int selectCountByExample(Object example);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据实体中的属性进行查询，只能有一个返回值，有多个结果是抛出异常，查询条件使用等号
         */
        T selectOne(T model);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据实体属性和RowBounds进行分页查询
         */
        List<T> selectByRowBounds(T model, RowBounds rowBounds);
    
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 单表分页查询
         */
        PageInfo selectPage(int pageNum, int pageSize, T model);
    
        /**
         * Created by JoyLau on 4/6/2017.
         * 2587038142.liu@gmail.com
         * 根据Example条件进行分页查询
         */
        PageInfo selectPageByExample(int pageNum, int pageSize, Object example);
```


## 怎么使用？
很简单
- 你的Mapper继承BaseMapper
- 你的Service继承BaseService
- 你的ServiceImpl实现你的Service借口，再继承BaseServiceImpl
- 你的Model继承BaseModel

## 来试一下
- 在你的ServiceImpl里点一下方法试试? 是不是很棒???
- 在你的Mapper里再点一下方法试试?? 6666...

## 最后
- 能想到的我都写了，BaseMapper和BaseServiceImpl基本上不需要扩展了，有不明白的可以联系我
- 欢迎指正，共同学习