---
title: 关于Jdk 8 Stream Distinct 去重复使用记录
date: 2018-3-1 17:39:30
description: java 8 lamda 表达式的 stream 有很多实用的方法，这里记录下去重复 distinct() 的使用
categories: [Java篇]
tags: [java]
---

<!-- more -->


### 说明
最近在 lamda 的 stream 进行 list 去重复的时候，发现没有生效
代码如下：

``` java 
    Map<String, Map<String, List<FollowAnalysisPojo>>> maps = allList
                .parallelStream()
                .distinct()
                .collect(Collectors.groupingBy(FollowAnalysisPojo::getMainPlateNum,Collectors.groupingBy(FollowAnalysisPojo::getPlateNum)));
```

实体类：

``` java 
    @Data
    public class FollowAnalysisPojo {
        /*被跟车牌*/
        private String mainPlateNum;
        /*跟踪车牌*/
        private String plateNum;
        private String vehicleType;
        private String siteName;
        private String directionName;
        /*车主时间*/
        private String passTimeMain;
        /*伴随时间*/
        private String passTimeSub;
        /*跟踪次数*/
        private Integer trackCount;
    
        /*该条记录被跟踪车占据的行数，用于在前端合并单元格*/
        private Integer mainRowSpan = 0;
    
        /*该条记录跟踪车占据的行数，用于在前端合并单元格*/
        private Integer rowSpan;
    
        private String key = UUID.randomUUID().toString();
      }

```

上面的代码是想做 先对查询出来的数据进行去重复的操作，然后在按照被跟车牌和跟踪车牌进行分组操作
有点需要说明的是 `parallelStream()` 比我们常用的 `stream()` 是并行多管操作，速度上更快

然后发现的问题是并没有去重复，当时也在奇怪 distinct() 里并没有任何参数来指定如何使用规则来去重复

### 正解
重写List中实体类的 `equals()` 方法

``` java 
    @Data
    public class FollowAnalysisPojo {
        ......
        /**
         * 当车主时间,伴随时间都相同时，则认为是一个对象
         * @param obj 对象
         * @return Boolean
         */
        @Override
        public boolean equals(Object obj) {
            if(!(obj instanceof FollowAnalysisPojo))return false;
            FollowAnalysisPojo followAnalysisPojo = (FollowAnalysisPojo)obj;
            return passTimeMain.equals(followAnalysisPojo.passTimeMain) && passTimeSub.equals(followAnalysisPojo.passTimeSub);
        }
    }
```

这样我们就按照我自定义的规则进行去重复了
运行了一下，发现还是不起作用
debug了一下，发现根本没有执行重写的 equals 方法
原来还需要重写 `hashCode()` 方法
在 `equals()` 方法 执行前会先执行 `hashCode()` 方法

``` java 
    @Data
    public class FollowAnalysisPojo {
        ......
        /**
         * 重新 equals 方法必须重新 hashCode方法
         * @return int
         */
        @Override
        public int hashCode(){
            int result = passTimeMain.hashCode();
            result = 31 * result + passTimeMain.hashCode();
            return result;
        }
    }
```

这样就可以了。

## 2018-9-13 更新
如果我们不重写方法，有没有办法按照List中bean的某个属性来去重复呢？答案是有的，利用的是 stream 的 reduce，用一个set 来存放 key,代码如下：

``` java
    List<JSONObject> result = trails.stream()
                .filter(distinctByKey(VehicleTrail::getPlateNbr))
                .collect(Collectors.toList());


    private  <T> Predicate<T> distinctByKey(Function<? super T, ?> keyExtractor) {
        Set<Object> seen = ConcurrentHashMap.newKeySet();
        return t -> seen.add(keyExtractor.apply(t));
    }
```