---
title: Camunda --- ACT_HI_ACTINST 表中同一流程实例的活动节点排序
date: 2023-07-21 09:18:26
description: Camunda ACT_HI_ACTINST 表中同一流程实例的活动节点排序
cover: //s3.joylau.cn:9000/blog/Camunda-UUID-Sort-2.png
categories: [Camunda篇]
tags: [Camunda]
---

<!-- more -->

## 背景
有时我们想在同一个流程实例中查看流程从上到下的流转顺序， 效果像这样

![Camunda-1](//s3.joylau.cn:9000/blog/Camunda-UUID-Sort-1.jpg)

这时会到 **ACT_HI_ACTINST** 表里去查流程实例的节点信息

但是我们根据流程是 ID 去查数据的时候发现， 并没有很好的根据时间顺序进行排列，就比如上面的数据，在数据库反应的情况如下:

![Camunda-2](//s3.joylau.cn:9000/blog/Camunda-UUID-Sort-2.png)

可以看到 发起人和抄送人是几乎同时进行的，因为发起人发起后，第一个是抄送人任务， sendTask 的操作很快，创建时间 START_TIME 都是 2023-07-20 09:11:21  
 于是同一流程实例根据创建时间 START_TIME 排序就会出现问题，上面的数据就是抄送人跑到发起人前面去了

于是想着用没用其他的方法，来根据其他字段进行排序

## 解决方案
被我找到一个方案， 就是表里的主键 UUID  

Camunda 默认主键策略是 UUID  这个配置可以在配置文件中修改

```yaml
camunda:
  bpm:
    id-generator: strong
```

可以修改为 **simple**， **strong**， **prefixed**， 默认是 **strong**

strong 策略的实现是 StrongUuidGenerator， 源码位置在 `org.camunda.bpm.engine.impl.persistence.StrongUuidGenerator`

其中生成 ID 的 **getNextId** 方法是使用的 **fasterxml** 的 **TimeBasedGenerator**， 源码位置在 `com.fasterxml.uuid.impl.TimeBasedGenerator`

从名字可以看出是基于时间生成的，实际上生成的是 UUID 的 version 1 版本

于是就是可以根据时间来排序了

## 具体操作
继续翻源码， 我们来到 **java-uuid-generator-3.2.0.jar** 这个依赖包， 其中 2 个类引起了我的注意
**UUIDUtil** 和 **UUIDComparator**

那么排序就很简单了， 如下代码就可轻松排序：


```java
public class UUIDTimeOrderTest {
    public static void main(String[] args) {
        String[] demos = ("c0767f45-0367-11ee-9698-8edff34f00ff,c07aec28-0367-11ee-9698-8edff34f00ff,c167211a-0367-11ee-9698-8edff34f00ff,c1687fb5-0367-11ee-9698-8edff34f00ff,c169b840-0367-11ee-9698-8edff34f00ff,c16b8d0b-0367-11ee-9698-8edff34f00ff").split(",");
        Arrays.stream(demos)
                .sorted((s1, s2) -> UUIDComparator.staticCompare(UUIDUtil.uuid(s1), UUIDUtil.uuid(s2)))
                .forEach(s -> System.out.println(s));
    }

}
```