---
title: 关于Jdk 8 Stream 的使用记录
date: 2018-12-24 23:27:38
description: java 8 lamda 表达式的 stream 有很多实用的方法，这里记录下日常的使用记录
categories: [Java篇]
tags: [java]
---

<!-- more -->

## LocalDateTime 将 long 格式的时间转化本地时间字符串

``` java
    LocalDateTime
            .ofEpochSecond(System.currentTimeMillis() / 1000, 0, ZoneOffset.ofHours(8))
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
```

## reduce 导致的源集合对象改变
例如下属代码导致 images 里的 DataImage 对象里的 stake 对象的数量改变

``` java
     Map<String,List<HighwayStake>> roadStakeMap = images.stream()
                    .filter(image -> !image.getStakes().isEmpty())
                    .map(DataImage::getStakes())
                    .reduce((highwayStakes, highwayStakes2) -> {
                        highwayStakes2.addAll(highwayStakes);
                        return highwayStakes2;
                    })
                    .orElse(new ArrayList<>())
                    .stream()
                    .collect(Collectors.groupingBy(HighwayStake::getDlmc));
```

因为对 dataImage 的 stakes 集合进行了合并,将 map 操作改为 复制一个新的 list , 而不是操作原来的 stakes

``` java
     Map<String,List<HighwayStake>> roadStakeMap = images.stream()
                    .filter(image -> !image.getStakes().isEmpty())
                    .map(dataImage -> new ArrayList<>(dataImage.getStakes()))
                    .reduce((highwayStakes, highwayStakes2) -> {
                        highwayStakes2.addAll(highwayStakes);
                        return highwayStakes2;
                    })
                    .orElse(new ArrayList<>())
                    .stream()
                    .collect(Collectors.groupingBy(HighwayStake::getDlmc));
```

## List 的深度拷贝
上述的问题实际上是一个 list 的拷贝,而且是 浅度复制

`new ArrayList<>(list)` 和 `Collections.copy(dest,src)` 都是浅度复制

下面代码是一个靠谱的 深度拷贝, 需要 T 实现序列化接口

``` java
    /**
     * list 深度复制
     */
    public static <T> List<T> deepCopy(List<T> source) {
        ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
        List<T> dest = new ArrayList<>();
        try {
            ObjectOutputStream out = new ObjectOutputStream(byteOut);
            out.writeObject(source);

            ByteArrayInputStream byteIn = new ByteArrayInputStream(byteOut.toByteArray());
            ObjectInputStream in = new ObjectInputStream(byteIn);
            dest = (List<T>) in.readObject();
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return dest;
    }
```


## reduce() 使用记录
reduce 有三种方法可以使用:

- `Optional<T> reduce(BinaryOperator<T> accumulator)`
- `T reduce(T identity, BinaryOperator<T> accumulator)`
- `<U> U reduce(U identity,BiFunction<U, ? super T, U> accumulator,BinaryOperator<U> combiner)`

第一种传入二元运算表达式,第二种是带初始值的二元运算表达式,这里着重记录下第三种的使用方式

第三种第一个参数方法的返回值类型,
第二个参数是一个二元运算表达式,这个表达式的第一个参数是方法的返回值,也就是方法的第一个参数,第二个参数是 Stream 里的值
第三个参数也是一个二元运算表达式,表达式的2个参数都是方法返回值的类型,用于对返回值类型的操作

第三个参数在非并发的情况下返回任何类型(甚至是 null)都没有影响,因为在非并发情况下,第三个二元表达式根本不会执行

那么第三个二元表达式用在并发的情况下,在并发的情况下,第二个二元表达式的第一个参数始终是方法的第一个类型,第三个三元表达式用于将不同线程操作的结果汇总起来


## map() 和 flatMap()
区别在于, map() 返回自定义对象, 而 flatMap() 返回 Stream 流对象


## distinct() 使用记录
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

### 2018-9-13 更新
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

## 2个集合的元素两两组合成一个 n * m 的集合 (笛卡尔积)

``` java
    Integer[] xs = new Integer[]{3, 4};
    Integer[] ys = new Integer[]{5, 6};

    List<Image> images = Arrays.stream(xs).flatMap(x -> Arrays.stream(ys).map(y -> new Image(x,y))).collect(Collectors.toList());

```

## 集合合并
比如: List<List<Demo>> list 将所有的 Demo 合并到一个集合;

1. reduce

```java
    // 第一种
    List<Demo> demos  = list.stream().reduce(new ArrayList<>(),(demo1,demo2) -> {demo1.addAll(demo2); return demo2;});
    
    // 第二种
    List<Demo> demos  = list.stream().reduce(new ArrayList<>(),(demo1,demo2) -> Stream.concat(demo1.stream(),demo2.stream()).collect(Collectors.toList()));
```

2. flatMap

```java
    List<Demo> demos = list.stream().flatMap(Collection::stream).collect(Collectors.toList());
```