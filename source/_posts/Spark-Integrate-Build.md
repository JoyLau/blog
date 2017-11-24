---
title: 大数据之路 Spark 环境搭建
date: 2017-11-23 14:19:37
description: 记录这篇 Spark 环境搭建与之前那篇 Hadoop 环境搭建相呼应
categories: [大数据篇]
tags: [Spark]
---

<!-- more -->
## 准备工作
### 首先
首先要说明的是,本篇文章用的  Spark 的版本都是目前最新版,直接在官网上下载就可以了,有注意的,下面详细说
有些命令可能已经不适应之前的旧版本了,以最新的版的为准
以下操作命令均是在服务的根目录下,使用的是相对目录

### 当前版本说明
- jdk 1.8.0
- Hadoop 版本2.8.2
- 操作系统版本 centos 7.2
- Spark 2.2.0

### 首先需要做的
安装 jdk 环境,再此不做详细叙述了,需要注意的是 jdk 的环境变量的配置
安装 Hadoop 环境,必须安装 Hadoop 才能使用 Spark，但如果使用 Spark 过程中没用到 HDFS，不启动 Hadoop 也是可以的

## 安装 Spark
打开官网下载的地址: http://spark.apache.org/downloads.html
需要注意的是,在选择下载包类型 `Choose a package type` 这个需要根据安装的 Hadoop 的版本来定的,或者直接选择  `Pre-build with user-provided Apache Hadoop `
这样我们可以自己配置 Hadoop 的版本

下载后,解压

进入 conf目录拷贝一份配置文件

``` bash
    cp ./conf/spark-env.sh.template ./conf/spark-env.sh
```

加入环境变量

``` bash
    export SPARK_DIST_CLASSPATH=$(/home/hadoop-2.8.2/bin/hadoop classpath)
```

我们运行 

``` bash
    # ./sbin/start-all.sh
```
Spark 便会运行起来,查看地址 : http://localhost:8080  可查看到集群情况


## 运行 Spark 示例程序
正如前面的 Hadoop 一样, Spark 自带有很多示例程序,目录在 ./example 下面,有 Java 的 Python,Scala ,R 语言的,
这里我们选个最熟悉的 Java 版的来跑下

我们找到 Java 的目录里也能看到里面有很多程序,能看到我们熟悉的 wordcount

这里我们跑个 计算π的值

``` bash
    # ./bin/run-example SparkPi
```

运行后控制台打印很多信息,但是能看到这么一行:

_**Pi is roughly 3.1432557162785812**_

这就可以了

## RDD
>> RDD : Spark 的分布式的元素集合（distributed collection of items），称为RDD（Resilient Distributed Dataset，弹性分布式数据集），它可被分发到集群各个节点上，进行并行操作。RDDs 可以通过 Hadoop InputFormats 创建（如 HDFS），或者从其他 RDDs 转化而来

我就简单的理解为 类比 Hadoop 的 MapReduce

RDDs 支持两种类型的操作

- actions: 在数据集上运行计算后返回值
- transformations: 转换, 从现有数据集创建一个新的数据集

## Spark-Shell
Spark-shell 支持 Scala 和 Python 2中语言,这里我们就用 Scala 来做,关于 Scala 的使用和语法我打算新写一篇文章来记录下,
在之前我也写过 在 maven 中集成使用 Scala 来编程,这里我先用下

执行 shell 

``` bash
    # ./bin/spark-shell
    
    To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
    17/11/24 09:33:36 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
    17/11/24 09:33:37 WARN util.Utils: Your hostname, JoyLinux resolves to a loopback address: 127.0.0.1; using 10.0.2.15 instead (on interface enp0s3)
    17/11/24 09:33:37 WARN util.Utils: Set SPARK_LOCAL_IP if you need to bind to another address
    Spark context Web UI available at http://10.0.2.15:4040
    Spark context available as 'sc' (master = local[*], app id = local-1511487218050).
    Spark session available as 'spark'.
    Welcome to
          ____              __
         / __/__  ___ _____/ /__
        _\ \/ _ \/ _ `/ __/  '_/
       /___/ .__/\_,_/_/ /_/\_\   version 2.2.0
          /_/
    
    Using Scala version 2.11.8 (OpenJDK 64-Bit Server VM, Java 1.8.0_151)
    Type in expressions to have them evaluated.
    Type :help for more information.
    
    scala>
```

来执行一个文本统计

``` bash
    scala> val textFile = sc.textFile("file:///home/hadoop-2.8.2/input/test.txt").count()
    
    textFile: Long = 4
```

默认读取的文件是 Hadoop HDFS 上的,上面的示例是从本地文件读取

来一个从 HDFS 上读取的,在这里我们之前在 HDFS 上传了个 tets.txt 的文档,在这里就可以直接使用了

``` bash
    scala> val textFile = sc.textFile("test2.txt");textFile.count()
    
    textFile: org.apache.spark.rdd.RDD[String] = test2.txt MapPartitionsRDD[19] at textFile at <console>:26
    res7: Long = 4
```

可以看到结果是一样的

## Spark SQL 和 DataFrames
Spark SQL 是 Spark 内嵌的模块，用于结构化数据。在 Spark 程序中可以使用 SQL 查询语句或 DataFrame API。DataFrames 和 SQL 提供了通用的方式来连接多种数据源，支持 Hive、Avro、Parquet、ORC、JSON、和 JDBC，并且可以在多种数据源之间执行 join 操作。

下面仍在 Spark shell 中演示一下 Spark SQL 的基本操作，该部分内容主要参考了 Spark SQL、DataFrames 和 Datasets 指南。

Spark SQL 的功能是通过 SQLContext 类来使用的，而创建 SQLContext 是通过 SparkContext 创建的。

``` bash
    scala> var df = spark.read.json("file:///home/spark-2.2.0-bin-without-hadoop/examples/src/main/resources/employees.json")
    df: org.apache.spark.sql.DataFrame = [name: string, salary: bigint]
    
    scala> df.show()
    +-------+------+
    |   name|salary|
    +-------+------+
    |Michael|  3000|
    |   Andy|  4500|
    | Justin|  3500|
    |  Berta|  4000|
    +-------+------+
    
    
    scala>
```

再来执行2条查询语句
`df.select("name").show()`
`df.filter(df("salary")>=4000).show()`

``` bash
    scala> df.select("name").show()
    +-------+
    |   name|
    +-------+
    |Michael|
    |   Andy|
    | Justin|
    |  Berta|
    +-------+
    
    
    scala> df.filter(df("salary")>=4000).show()
    +-----+------+
    | name|salary|
    +-----+------+
    | Andy|  4500|
    |Berta|  4000|
    +-----+------+
```

执行一条 sql 语句试试

``` bash
    scala> df.registerTempTable("employees")
    warning: there was one deprecation warning; re-run with -deprecation for details
    
    scala> spark.sql("select * from employees").show()
    +-------+------+
    |   name|salary|
    +-------+------+
    |Michael|  3000|
    |   Andy|  4500|
    | Justin|  3500|
    |  Berta|  4000|
    +-------+------+
    
    
    scala> spark.sql("select * from employees where salary >= 4000").show()
    +-----+------+
    | name|salary|
    +-----+------+
    | Andy|  4500|
    |Berta|  4000|
    +-----+------+
```

其实还有很多功能呢, http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrame ,这里先写2个试试,后续再细节学习

这篇文章暂时先写到这,还有后续的 Spark Streaming ,想先学学看流式计算Storm,之后对比下看看写一篇文章

接下来,熟悉 Scala 语法写一个 JavaScala 应用程序来通过 SparkAPI 单独部署一下试试

### 感受
这篇文章写下来等于将当时搭建 Spark 环境重复了一遍, 也是一遍敲命令,一遍记录下来,温故而知新,自己也学到不少东西,棒棒哒💯