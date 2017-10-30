---
title: SpringBoot 读取 JSON 文件并转化为 JSON 对象
date: 2017-10-30 11:04:13
description: "有时候在项目中用 JSONObject 构建一个复杂的 json 对象会很麻烦，要写很多代码，如果我们事先写一个 json 模板文件，读取后在将里面某些属性更改为我们自己定义的，这样的话会省事很多"
categories: [SpringBoot篇]
tags: [SpringBoot,JSON]
---

<!-- more -->
### 通过注解读取文件
``` java
    @Value("classpath:static/json/addTask.json")
    Resource addTaskJson;
```

### 其他配置
| 前缀 | 例子 | 说明 |
|:-----|:-----|:-----|
| classpath: | classpath:com/myapp/config.xml | 从classpath中加载 |
| file: | file:/data/config.xml | 作为 URL 从文件系统中加载 |
| http: | http://myserver/logo.png | 作为 URL 加载 |
| (none) | /data/config.xml | 根据 ApplicationContext 进行判断 |

摘自于Spring Framework参考手册

### 转化为 字符串 转化为 JSON 对象
``` java
    String jsonStr = new String(IOUtils.readFully(addTaskJson.getInputStream(), -1,true));
    JSONObject json = JSONObject.parseObject(jsonStr);
```

注意： 该方法需要 jdk1.8的环境