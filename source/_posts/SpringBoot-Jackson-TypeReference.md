---
title: SpringBoot --- Jackson TypeReference 动态定义泛型类型
date: 2021-09-01 16:01:55
description: SpringBoot --- Jackson TypeReference 动态定义泛型类型
categories: [SpringBoot]
tags: [Jackson,SpringBoot]
---

<!-- more -->

### 说明
jackson 中将 json 转为 Java 复杂对象一般会使用 new TypeReference<List<User>>(){} 的匿名内部类来实现

这种方式有 2 个缺点
1. 会不符合一些代码检测规范，比如 spotbugs， 会报出 `SIC_INNER_SHOULD_BE_STATIC_ANON` 规范检查
2. 无法动态的指定泛型类型

### 解决方式
使用 `TypeFactory` 类中的 `constructParametricType` 方法来解决泛型问题

使用示例

```java
    public class TypeReferenceApiResult<T> extends TypeReference<ApiResult<T>> {

        protected final Type type;
    
        public TypeReferenceApiResult(Class<T> clazz) {
            type = new ObjectMapper().getTypeFactory().constructParametricType(ApiResult.class, clazz);
        }
    
    
        @Override
        public Type getType() {
            return type;
        }
    }
```

``` java
    ApiResult<UserCreateResult> apiResult = new ObjectMapper()
        .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
        .readValue(response.getContentAsByteArray(),
        new TypeReferenceApiResult<>(UserCreateResult.class));
```

使用 TypeReferenceApiResult 对象会被反序列化为 `ApiResult<T>` 的泛型类型, 其中可以通过传入构造参数指定 T 的 class 类型

### 扩展
TypeFactory 内置了很多生成 JavaType 的方法，用于生成各类 JavaType 对象

1. constructCollectionType
2. constructMapLikeType
3. constructParametricType
4. ...

详情可以使用 `new ObjectMapper().getTypeFactory()` 再查看其中的方法查看更多的 JavaType 类型