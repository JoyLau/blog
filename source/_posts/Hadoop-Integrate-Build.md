---
title: 大数据之路 Hadoop 环境搭建
date: 2017-11-22 10:36:07
description: 虽然说 Hadoop 的环境在我本地早就搭建好了,现在回想起来,还是有点坑的,在这里记录一下吧
categories: [大数据篇]
tags: [Hadoop]
---

<!-- more -->
## 首先
首先要说明的是,本篇文章用的 Hadoop 的版本都是目前最新版,直接在官网上下载就可以了
有些命令可能已经不适应之前的旧版本了,以最新的版的为准
以下操作命令均是在服务的根目录下,使用的是相对目录

### 当前版本说明
- Hadoop 版本2.8.0
- 操作系统版本 centos 7.2

## 首先需要做的
安装 jdk 环境,再此不做详细叙述了,需要注意的是 jdk 的环境变量的配置

`yum install openjdk1.8xxxxx` 这个安装的是 jre环境,并不是 jdk,安装 jdk

``` shell
    sudo yum install java-1.7.0-openjdk java-1.8.0-openjdk-devel
```

配置环境变量

``` shell
    vim ~/.bashrc
```

最后一行添加

``` shell
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
```

紧接着,让环境变量生效

``` shell
    source ~/.bashrc    # 使变量设置生效
```

设置好之后,再看下是否生效了

``` cmd
    echo $JAVA_HOME     # 检验变量值
    java -version
    $JAVA_HOME/bin/java -version  # 与直接执行 java -version 一样就没什么问题了
```

## Hadoop 单机环境搭建及测试运行
官网下载 Hadoop 包

上传到服务器上,解压 tar -zxf hadoop-2.8.2.tar.gz
解压完了,我们可以查看下版本信息

``` cmd
    bin/hadoop version
    
    Hadoop 2.8.2
    Subversion https://git-wip-us.apache.org/repos/asf/hadoop.git -r 66c47f2a01ad9637879e95f80c41f798373828fb
    Compiled by jdu on 2017-10-19T20:39Z
    Compiled with protoc 2.5.0
    From source with checksum dce55e5afe30c210816b39b631a53b1d
    This command was run using /home/hadoop-2.8.2/share/hadoop/common/hadoop-common-2.8.2.jar
```

出现上述信息就没有什么问题

接下来,就可以运行 Hadoop 自带的列子了,例子的目录在 /share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.0.jar

``` cmd
    // 创建1个输入目录,输出目录不用创建,在命令中会自动创建,如果创建了,会提示目录已经存在,再次运行示例程序化,删除输出目录即可
    mkdir ./input
    
    // 看看都有哪些例子
    ./bin/hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.2.jar
    
    An example program must be given as the first argument.
    Valid program names are:
      aggregatewordcount: An Aggregate based map/reduce program that counts the words in the input files.
      aggregatewordhist: An Aggregate based map/reduce program that computes the histogram of the words in the input files.
      bbp: A map/reduce program that uses Bailey-Borwein-Plouffe to compute exact digits of Pi.
      dbcount: An example job that count the pageview counts from a database.
      distbbp: A map/reduce program that uses a BBP-type formula to compute exact bits of Pi.
      grep: A map/reduce program that counts the matches of a regex in the input.
      join: A job that effects a join over sorted, equally partitioned datasets
      multifilewc: A job that counts words from several files.
      pentomino: A map/reduce tile laying program to find solutions to pentomino problems.
      pi: A map/reduce program that estimates Pi using a quasi-Monte Carlo method.
      randomtextwriter: A map/reduce program that writes 10GB of random textual data per node.
      randomwriter: A map/reduce program that writes 10GB of random data per node.
      secondarysort: An example defining a secondary sort to the reduce.
      sort: A map/reduce program that sorts the data written by the random writer.
      sudoku: A sudoku solver.
      teragen: Generate data for the terasort
      terasort: Run the terasort
      teravalidate: Checking results of terasort
      wordcount: A map/reduce program that counts the words in the input files.
      wordmean: A map/reduce program that counts the average length of the words in the input files.
      wordmedian: A map/reduce program that counts the median length of the words in the input files.
      wordstandarddeviation: A map/reduce program that counts the standard deviation of the length of the words in the input files.
```

接下来,跑一个经典的 wordcount ,再次之前,我们创建一个文本以供程序统计

``` cmd
    cat input/test.txt
    vi input/test.txt
    
    插入一些字符
```

开始记录

``` cmd
    ./bin/hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.2.jar wordcount ./input/test.txt ./output/
```

截取部分输出

``` txt
    17/11/22 11:30:08 INFO mapred.LocalJobRunner: reduce > reduce
    17/11/22 11:30:08 INFO mapred.Task: Task 'attempt_local1247748922_0001_r_000000_0' done.
    17/11/22 11:30:08 INFO mapred.LocalJobRunner: Finishing task: attempt_local1247748922_0001_r_000000_0
    17/11/22 11:30:08 INFO mapred.LocalJobRunner: reduce task executor complete.
    17/11/22 11:30:08 INFO mapreduce.Job: Job job_local1247748922_0001 running in uber mode : false
    17/11/22 11:30:08 INFO mapreduce.Job:  map 100% reduce 100%
    17/11/22 11:30:08 INFO mapreduce.Job: Job job_local1247748922_0001 completed successfully
    17/11/22 11:30:08 INFO mapreduce.Job: Counters: 30
    	File System Counters
    		FILE: Number of bytes read=605002
    		FILE: Number of bytes written=1267054
    		FILE: Number of read operations=0
    		FILE: Number of large read operations=0
    		FILE: Number of write operations=0
    	Map-Reduce Framework
    		Map input records=38
    		Map output records=35
    		Map output bytes=277
    		Map output materialized bytes=251
    		Input split bytes=103
    		Combine input records=35
    		Combine output records=23
    		Reduce input groups=23
    		Reduce shuffle bytes=251
    		Reduce input records=23
    		Reduce output records=23
    		Spilled Records=46
    		Shuffled Maps =1
    		Failed Shuffles=0
    		Merged Map outputs=1
    		GC time elapsed (ms)=21
    		Total committed heap usage (bytes)=461250560
    	Shuffle Errors
    		BAD_ID=0
    		CONNECTION=0
    		IO_ERROR=0
    		WRONG_LENGTH=0
    		WRONG_MAP=0
    		WRONG_REDUCE=0
    	File Input Format Counters
    		Bytes Read=140
    	File Output Format Counters
    		Bytes Written=165
```

看下输出情况

``` xml
    # cat output/*
    hello	1
    jjjjj	1
    joylau	2
    world	1
```

可以看到每个单词出现的次数

## Hadoop 伪分布式环境搭建
我们需要设置 HADOOP 环境变量

``` cmd
    gedit ~/.bashrc
    
    export HADOOP_HOME=/home/hadoop-2.8.0
    export HADOOP_INSTALL=$HADOOP_HOME
    export HADOOP_MAPRED_HOME=$HADOOP_HOME
    export HADOOP_COMMON_HOME=$HADOOP_HOME
    export HADOOP_HDFS_HOME=$HADOOP_HOME
    export YARN_HOME=$HADOOP_HOME
    export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
    export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
    
    source ~/.bashrc
    
```

修改配置文件
### core-site.xml
``` xml
    <configuration>
      <property>
            <name>hadoop.tmp.dir</name>
            <value>file:/home/temp</value>
            <description>Abase for other temporary directories.</description>
        </property>
        <property>
            <name>fs.defaultFS</name>
            <value>hdfs://localhost:9000</value>
        </property>
    </configuration>
```

### hdfs-site.xml
``` xml
    <configuration>
     <property>
            <name>dfs.replication</name>
            <value>1</value>
        </property>
        <property>
            <name>dfs.namenode.name.dir</name>
            <value>file:/home/temp/hdfs/namenode</value>
        </property>
        <property>
            <name>dfs.datanode.data.dir</name>
            <value>file:/home/temp/hdfs/datanode</value>
        </property>
    </configuration>
```

配置完成后，执行 NameNode 和 DataNode 的格式化:

``` cmd
    ./bin/hdfs namenode -format
    ./bin/hdfs datanode -format
```

现在启动 Hadoop 伪分布式服务器

``` cmd
    ./sbin/start-dfs.sh 
    ./sbin/start-yarn.sh
```

以前版本的命令是

``` cmd
    ./sbin/start-all.sh
```

jps查看启动是否成功启动

``` cmd
    jps
    
    5360 Jps
    4935 ResourceManager
    5225 NodeManager
    4494 NameNode
    4782 SecondaryNameNode
```

成功启动后，可以访问 Web 界面 http://localhost:50070 查看 NameNode 和 Datanode 信息，还可以在线查看 HDFS 中的文件
运行 stop-all.sh 来关闭所有进程

## 伪分布式环境实例运行
上面实例的运行时单机版的,伪分布式的实例的运行的不同之处在于,读取文件是在 HDFS 上的

按照常规的尿性,我们先创建个用户目录 ,以后就可以以相对目录来进行文件的操作了

这里得说下 hdfs 的常用 shell

- 创建目录 `./bin/hdfs dfs -mkdir -p /user/root`
- 上传文档 `./bin/hdfs dfs -put ./input/test.txt input`
- 删除文档 `./bin/hdfs dfs -rmr input`
- 产看文档 `./bin/hdfs dfs -cat input/*`
- 查看列表 `./bin/hdfs dfs -ls input`
- 拉取文档 `./bin/hdfs dfs -get output/* ./output`

有了这些简单的命令,现在就可以运行实例

先创建用户目录 `./bin/hdfs dfs -mkdir -p /user/root`
在新建一个目录 `./bin/hdfs dfs -mkdir input`
将之前的文件上传 `./bin/hdfs dfs -put ./input/test.txt input`
上传成功后还可以查看下时候有文件 `./bin/hdfs dfs -ls input`
运行实例  `./bin/hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.2.jar wordcount input/ output/`
查看运行结果 `./bin/hdfs dfs -cat output/*`

其实这些命令都是类 linux 命令,熟悉 linux 命令,这些都很好操作

可以看到统计结果和单机版是一致的

将结果导出 `./bin/hdfs dfs -get output ./output`

其实 在 http://host:50070/explorer.html#/user/root 可以看到上传和输出的文件目录

### YARN 启动
伪分布式不启动 YARN 也可以，一般不会影响程序执行
YARN 是从 MapReduce 中分离出来的，负责资源管理与任务调度。YARN 运行于 MapReduce 之上，提供了高可用性、高扩展性

首先修改配置文件 mapred-site.xml，这边需要先进行重命名：

``` cmd
    mv ./etc/hadoop/mapred-site.xml.template ./etc/hadoop/mapred-site.xml
```

增加配置

``` xml
    <configuration>
        <property>
            <name>mapreduce.framework.name</name>
            <value>yarn</value>
        </property>
    </configuration>
```

配置文件 yarn-site.xml：

``` xml
    <configuration>
        <property>
            <name>yarn.nodemanager.aux-services</name>
            <value>mapreduce_shuffle</value>
            </property>
    </configuration>
```

``` cmd
    ./sbin/start-yarn.sh      $ 启动YARN
    ./sbin/mr-jobhistory-daemon.sh start historyserver  # 开启历史服务器，才能在Web中查看任务运行情况
```

启动 YARN 之后，运行实例的方法还是一样的，仅仅是资源管理方式、任务调度不同。
观察日志信息可以发现，不启用 YARN 时，是 “mapred.LocalJobRunner” 在跑任务，
启用 YARN 之后，是 “mapred.YARNRunner” 在跑任务。
启动 YARN 有个好处是可以通过 Web 界面查看任务的运行情况：http://localhost:8088/cluster

## 踩坑记录
- 内存不足:一开始虚拟机只开了2G 内存,出现了很多错误,后来将虚拟机内存开到8G, 就没有问题了
- hosts 配置,一开始启动的时候会报不识别 localhost 的域名的错误,更改下 hosts文件即可,加一行

``` xml
    127.0.0.1   localhost HostName
```

### 参考资料
《Hadoop 权威指南 : 第四版》 --Tom White 著

### 感受
这篇文章写下来等于将当时搭建 Hadoop 环境重复了一遍,花了不少功夫的,一遍敲命令,一遍记录下来,温故而知新,自己也学到不少东西,棒棒哒💯