---
title: 重剑无锋,大巧不工 SpringBoot --- @RequestBody JSON参数处理
date: 2017-6-12 09:30:21
update_o: 1
description: "在Spring的项目里，如SpringBoot，SpringMVC，我们经常会传入JSON格式的参数进行处理<br>近期我遇到这样一个问题：如果我传进去的JSON对象属性比接受的对象属性要多的话，这时候会出现问题"
categories: [SpringBoot篇]
tags: [Spring,SpringMVC,SpringBoot,JSON]
---

<!-- more -->

## 问题

- 用jackson 作为json转换器的时候，如果传入的json的key 比接收对象多的话，就会报错


## 解决

### 先看下SpringMVC原来的配置
``` xml 
            <mvc:message-converters register-defaults="true">
                <bean class="org.springframework.http.converter.json.MappingJackson2HttpMessageConverter">
                    <property name="supportedMediaTypes" value="application/json" />
                    <property name="objectMapper" ref="jacksonObjectMapper" />			
                </bean>
                <bean class="org.springframework.http.converter.StringHttpMessageConverter">
                    <property name="supportedMediaTypes">  
                        <list>  
                          	<value>text/plain;charset=UTF-8</value>
                            <value>text/html;charset=UTF-8</value>
                            <value>application/json;charset=UTF-8</value>  
                        </list>  
                    </property>		
                </bean>
            </mvc:message-converters>
```

这里的json转换器配置的是:`org.springframework.http.converter.json.MappingJackson2HttpMessageConverter`

我们进入到这个类中发现，这个类是继承的 `AbstractJackson2HttpMessageConverter`

而 `AbstractJackson2HttpMessageConverter` 继承的是 `AbstractHttpMessageConverter<Object>` 
找到这个包下面 有一个类 `GsonHttpMessageConverter` 同样继承的 `AbstractHttpMessageConverter<Object>`
OK，就是他了 


``` xml
            <mvc:message-converters register-defaults="true">
                <bean class="org.springframework.http.converter.json.GsonHttpMessageConverter"></bean>
                <bean class="org.springframework.http.converter.StringHttpMessageConverter">
                    <property name="supportedMediaTypes">  
                        <list>  
                          	<value>text/plain;charset=UTF-8</value>
                            <value>text/html;charset=UTF-8</value>
                            <value>application/json;charset=UTF-8</value>  
                        </list>  
                    </property>		
                </bean>
            </mvc:message-converters>
```

这样，参数就随便你整吧，多点少点杜无所谓，完全匹配不上就返回个{}给你

### 来看下fastjson 

fastjson下面有这个一个 package : `com.alibaba.fastjson.support.spring`

根据字面意思可知，这里是对spring的支持

找到下面这个class `FastJsonHttpMessageConverter`

``` java
    public class FastJsonHttpMessageConverter extends AbstractHttpMessageConverter<Object>
```
OK，这个类同样也是继承了 AbstractHttpMessageConverter<Object> 

只要把这个类注入进去就可以了


### SpringBoot使用FastJSON解析数据

- 第一种继承WebMvcConfigurerAdapter，重写configureMessageConverters方法：

``` java
    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        super.configureMessageConverters(converters);
        FastJsonHttpMessageConverter converter=new FastJsonHttpMessageConverter();
        FastJsonConfig fastJsonConfig= new FastJsonConfig();
        fastJsonConfig.setSerializerFeatures(SerializerFeature.PrettyFormat);
        converter.setFastJsonConfig(fastJsonConfig);
        converters.add(converter);

    }
```

- 第二种方式bean注入HttpMessageConverters：

``` java
    @Bean  
    public HttpMessageConverters fastJsonHttpMessageConverters() {  
    FastJsonHttpMessageConverter fastConverter = new FastJsonHttpMessageConverter();  
    FastJsonConfig fastJsonConfig = new FastJsonConfig();  
    fastJsonConfig.setSerializerFeatures(SerializerFeature.PrettyFormat);  
    fastConverter.setFastJsonConfig(fastJsonConfig);  
    HttpMessageConverter<?> converter = fastConverter;  
    return new HttpMessageConverters(converter);  
    } 
```

