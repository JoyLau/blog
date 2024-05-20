---
title: MybatisPlus typeHandler 在 lambda 更新时不起作用的问题
date: 2024-05-20 11:48:05
description: MybatisPlus typeHandler 在 lambda 更新时不起作用的问题
categories: [MyBatis篇]
tags: [mybatis]
---


## 复现

实体类
```java
@Getter
@Setter
@TableName(autoResultMap = true)
public class AdapterManager implements Serializable {
    @Serial
    private static final long serialVersionUID = 3254095985232547523L;

    /**
     * id。
     */
    @TableId(type = IdType.AUTO)
    private Integer id;

    /**
     * 测试意向申请。
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<Attachment> letterIntent;
}

```

更新代码：
```java
        adapterManagerMapper.update(null, Wrappers.lambdaUpdate(AdapterManager.class)
                .eq(AdapterManager::getId, aid)
                .set(AdapterManager::getLetterIntent, list)
        );
```


在使用 lambdaUpdate 无法更新字段， 会报错 `Caused by: java.io.NotSerializableException: xxxxxx.Attachment`

<!-- more -->

## 解决
### 在 Java 中使用
新建一个实体类，然后将
将 lambdaUpdate 改为 updateById

### 在 XML 中使用
新增一个 resultMap
```xml
    <resultMap id="rm" type="com.hfky.terminal.adapter.modules.adapter.vo.AdapterResult">
        <result property="letterIntent" column="letter_intent" jdbcType="VARCHAR"
                typeHandler="com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler"/>
    </resultMap>
```

查询语句中使用 resultMap

```xml
<select id="list" resultMap="rm">
    select * from xxxx...
</select>
```

单个字段的类型处理
```xml
<result column="letter_intent" jdbcType="VARCHAR" property="letterIntent" typeHandler="com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler" />
```