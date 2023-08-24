---
title: Spring EL 表达式 ${} 和 #{}
date: 2019-11-20 10:20:15
description: Spring EL 表达式 ${} 和 #{} 的区别记录
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->

### 区别
个人理解:
`${}` : 用于加载外部文件中指定key的值
`#{}` : 功能更强大的SpEl表达式，将内容赋值给属性
`#{…}` 和 `${…}` 可以混合使用，但是必须`#{}`外面，${}在里面,#{ '${}' } ，注意单引号，注意不能反过来

### **#{}** 功能
1. 直接量表达式: "#{'Hello World'}"
2. 使用java代码new/instance of: 此方法只能是java.lang 下的类才可以省略包名 #{"new Spring('Hello World')"}
3. 使用T(Type): 使用“T(Type)”来表示java.lang.Class实例，同样，只有java.lang 下的类才可以省略包名。此方法一般用来引用常量或静态方法 ,#{"T(Integer).MAX_VALUE"}
4. 变量: 使用“#bean_id”来获取,#{"beanId.field"}
5. 方法调用: #{"#abc.substring(0,1)"}
6. 运算符表达式: 算数表达式,比较表达式,逻辑表达式,赋值表达式,三目表达式,正则表达式
7. 判断空: #{"name?:'other'"}


### 实例
springboot 和 elasticsearch 的整合包里有一个注解 
@Document(indexName = "", type = "")
indexName 和 type 都是字符串
这个注解写在实体类上,代表该实体类是一个索引
现在, indexName 和 type 不能为固定写死,需要从配置文件读取,
于是想到了 spring  的 el 表达式
使用 
@Document(indexName = "${xxxx}", type = "${xxxx}")
启动后
无效,spring 直接将其解析成了字符串
于是,查看 @Document 这个注解实现的源码
在这个包中 org.springframework.data.elasticsearch.core.mapping 找到了实现类 SimpleElasticsearchPersistentEntity
其中

``` java
    public SimpleElasticsearchPersistentEntity(TypeInformation<T> typeInformation) {
        super(typeInformation);
        this.context = new StandardEvaluationContext();
        this.parser = new SpelExpressionParser();

        Class<T> clazz = typeInformation.getType();
        if (clazz.isAnnotationPresent(Document.class)) {
            Document document = clazz.getAnnotation(Document.class);
            Assert.hasText(document.indexName(),
                    " Unknown indexName. Make sure the indexName is defined. e.g @Document(indexName=\"foo\")");
            this.indexName = document.indexName();
            this.indexType = hasText(document.type()) ? document.type() : clazz.getSimpleName().toLowerCase(Locale.ENGLISH);
            this.useServerConfiguration = document.useServerConfiguration();
            this.shards = document.shards();
            this.replicas = document.replicas();
            this.refreshInterval = document.refreshInterval();
            this.indexStoreType = document.indexStoreType();
            this.createIndexAndMapping = document.createIndex();
        }
        if (clazz.isAnnotationPresent(Setting.class)) {
            this.settingPath = typeInformation.getType().getAnnotation(Setting.class).settingPath();
        }
    }

    @Override
    public String getIndexName() {
        Expression expression = parser.parseExpression(indexName, ParserContext.TEMPLATE_EXPRESSION);
        return expression.getValue(context, String.class);
    }

    @Override
    public String getIndexType() {
        Expression expression = parser.parseExpression(indexType, ParserContext.TEMPLATE_EXPRESSION);
        return expression.getValue(context, String.class);
    }
```

我们看到了 `SpelExpressionParser` 和 `ParserContext.TEMPLATE_EXPRESSION`
那么这里就很肯定 indexName 和 type 是支持 spel 的写法了,只是怎么写,暂时不知道
再看
ParserContext.TEMPLATE_EXPRESSION 的源码是

``` java
    /**
     * The default ParserContext implementation that enables template expression
     * parsing mode. The expression prefix is "#{" and the expression suffix is "}".
     * @see #isTemplate()
     */
    ParserContext TEMPLATE_EXPRESSION = new ParserContext() {

        @Override
        public boolean isTemplate() {
            return true;
        }

        @Override
        public String getExpressionPrefix() {
            return "#{";
        }

        @Override
        public String getExpressionSuffix() {
            return "}";
        }
    };
```

看到上面的注释,知道是使用 #{} 
接着
新建一个类,使用 @Configuration 和 @ConfigurationProperties(prefix = "xxx") 注册一个 bean
再在实体类上加上注解 @Component 也注册一个bean
之后就可以使用 #{bean.indexName} 来读取到配置属性了

# Spring Boot 中手动解析表达式的值
有时候我们会在注解中使用 SPEL 表达式来读取配置文件中的指定值， 一般会使用类似于 【${xxx.xxx.xxx}】这样来使用
如果在代码中手动解析该表达式的值，可以使用 Environment 的以下方法

` environment.resolvePlaceholders(cidSpel) ` 或者 `environment.resolveRequiredPlaceholders(cidSpel)`