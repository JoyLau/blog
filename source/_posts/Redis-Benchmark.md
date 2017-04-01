---
title: Redis有多快??? --- 基准性能测试
date: 2017-4-1 13:42:38
description: "<img src='//image.joylau.cn/blog/Redis-Benchmark.jpg' alt='Redis-Benchmark'></br>Redis有多快???我们安装的Redis提供一个基准测试工具redis-benchmark，测一下就知道了....."
categories: [Redis篇]
tags: [redis]
---

<!-- more -->
![Redis-Benchmark](//image.joylau.cn/blog/Redis-Benchmark.jpg)



## 说明
- redis默认提供了性能测试的工具
- 在linux下文件是redis-benchmark
- 在windows下文件是redis-benchmark.exe

## 参数查看
- `redis-benchmark -h `
``` bash
    Usage: redis-benchmark [-h <host>] [-p <port>] [-c <clients>] [-n <requests]> [-
    k <boolean>]
    
     -h <hostname>      Server hostname (default 127.0.0.1)
     -p <port>          Server port (default 6379)
     -s <socket>        Server socket (overrides host and port)
     -a <password>      Password for Redis Auth
     -c <clients>       Number of parallel connections (default 50)
     -n <requests>      Total number of requests (default 100000)
     -d <size>          Data size of SET/GET value in bytes (default 2)
     -dbnum <db>        SELECT the specified db number (default 0)
     -k <boolean>       1=keep alive 0=reconnect (default 1)
     -r <keyspacelen>   Use random keys for SET/GET/INCR, random values for SADD
      Using this option the benchmark will expand the string __rand_int__
      inside an argument with a 12 digits number in the specified range
      from 0 to keyspacelen-1. The substitution changes every time a command
      is executed. Default tests use this to hit random keys in the
      specified range.
     -P <numreq>        Pipeline <numreq> requests. Default 1 (no pipeline).
     -q                 Quiet. Just show query/sec values
     --csv              Output in CSV format
     -l                 Loop. Run the tests forever
     -t <tests>         Only run the comma separated list of tests. The test
                        names are the same as the ones produced as output.
     -I                 Idle mode. Just open N idle connections and wait.
    
    Examples:
    
     Run the benchmark with the default configuration against 127.0.0.1:6379:
       $ redis-benchmark
    
     Use 20 parallel clients, for a total of 100k requests, against 192.168.1.1:
       $ redis-benchmark -h 192.168.1.1 -p 6379 -n 100000 -c 20
    
     Fill 127.0.0.1:6379 with about 1 million keys only using the SET test:
       $ redis-benchmark -t set -n 1000000 -r 100000000
    
     Benchmark 127.0.0.1:6379 for a few commands producing CSV output:
       $ redis-benchmark -t ping,set,get -n 100000 --csv
    
     Benchmark a specific command line:
       $ redis-benchmark -r 10000 -n 10000 eval 'return redis.call("ping")' 0
    
     Fill a list with 10000 random elements:
       $ redis-benchmark -r 10000 -n 10000 lpush mylist __rand_int__
    
     On user specified command lines __rand_int__ is replaced with a random integer
     with a range of values selected by the -r option.
```

## 开始测试
- 搞清了参数的含义，可以进行测试了
- 本次配置为Redis的默认配置，默认的配置项已经有足够好的性能表现了，不需要调优
- `redis-benchmark -h joylau.cn -p 6379 -a XXX -t get,set -n 1000 -c 400 -q`
    我是模仿了我自己现在公司的业务需求，测试了我直接服务器上的Redis，向redis服务器发送1000个请求，每个请求附带400个并发客户端，以静默显示
    ![redis-joylau-test-q](//image.joylau.cn/blog/redis-joylau-test-q.png)
    可以看到，set操作每秒处理17241次，get操作每秒处理17543次
- `redis-benchmark -h joylau.cn -p 6379 -a XXX -t get,set -n 1000 -c 400`
    同上，以标准格式显示
    ![redis-joylau-test](//image.joylau.cn/blog/redis-joylau-test.png)
    可以看到，set操作每秒处理17857次，get操作每秒处理18518次
- **_我自己也开了本地的服务器做测试，每秒操作次数可达100000次_**


## 一些参数说明
- -t : 可以选择你需要运行的测试用例
- -r : 设置随机数来SET/GET/INCR
- -P : 一次性执行多条命令，记得在多条命令需要处理时候使用 pipelining。
    
## 陷阱和错误的认识
>> 第一点是显而易见的：基准测试的黄金准则是使用相同的标准。 用相同的任务量测试不同版本的 Redis，或者用相同的参数测试测试不同版本 Redis。 如果把 Redis 和其他工具测试，那就需要小心功能细节差异。


- Redis 是一个服务器：所有的命令都包含网络或 IPC 消耗。这意味着和它和 SQLite， Berkeley DB， Tokyo/Kyoto Cabinet 等比较起来无意义， 因为大部分的消耗都在网络协议上面。
- Redis 的大部分常用命令都有确认返回。有些数据存储系统则没有（比如 MongoDB 的写操作没有返回确认）。把 Redis 和其他单向调用命令存储系统比较意义不大。
简单的循环操作 Redis 其实不是对 Redis 进行基准测试，而是测试你的网络（或者 IPC）延迟。想要真正测试 Redis，需要使用多个连接（比如 redis-benchmark)， 或者使用 pipelining 来聚合多个命令，另外还可以采用多线程或多进程。
- Redis 是一个内存数据库，同时提供一些可选的持久化功能。 如果你想和一个持久化服务器（MySQL, PostgreSQL 等等） 对比的话， 那你需要考虑启用 AOF 和适当的 fsync 策略。
- Redis 是单线程服务。它并没有设计为多 CPU 进行优化。如果想要从多核获取好处， 那就考虑启用多个实例吧。将单实例 Redis 和多线程数据库对比是不公平的。


## 影响 Redis 性能的因素
>> 有几个因素直接决定 Redis 的性能。它们能够改变基准测试的结果， 所以我们必须注意到它们。一般情况下，Redis 默认参数已经可以提供足够的性能， 不需要调优。


- 网络带宽和延迟通常是最大短板。建议在基准测试之前使用 ping 来检查服务端到客户端的延迟。根据带宽，可以计算出最大吞吐量。 比如将 4 KB 的字符串塞入 Redis，吞吐量是 100000 q/s，那么实际需要 3.2 Gbits/s 的带宽，所以需要 10 GBits/s 网络连接， 1 Gbits/s 是不够的。 在很多线上服务中，Redis 吞吐会先被网络带宽限制住，而不是 CPU。 为了达到高吞吐量突破 TCP/IP 限制，最后采用 10 Gbits/s 的网卡， 或者多个 1 Gbits/s 网卡。
- CPU 是另外一个重要的影响因素，由于是单线程模型，Redis 更喜欢大缓存快速 CPU， 而不是多核。这种场景下面，比较推荐 Intel CPU。AMD CPU 可能只有 Intel CPU 的一半性能（通过对 Nehalem EP/Westmere EP/Sandy 平台的对比）。 当其他条件相当时候，CPU 就成了 redis-benchmark 的限制因素。
- 在小对象存取时候，内存速度和带宽看上去不是很重要，但是对大对象（> 10 KB）， 它就变得重要起来。不过通常情况下面，倒不至于为了优化 Redis 而购买更高性能的内存模块。
- Redis 在 VM 上会变慢。虚拟化对普通操作会有额外的消耗，Redis 对系统调用和网络终端不会有太多的 overhead。建议把 Redis 运行在物理机器上， 特别是当你很在意延迟时候。在最先进的虚拟化设备（VMWare）上面，redis-benchmark 的测试结果比物理机器上慢了一倍，很多 CPU 时间被消费在系统调用和中断上面。
- 如果服务器和客户端都运行在同一个机器上面，那么 TCP/IP loopback 和 unix domain sockets 都可以使用。对 Linux 来说，使用 unix socket 可以比 TCP/IP loopback 快 50%。 默认 redis-benchmark 是使用 TCP/IP loopback。 当大量使用 pipelining 时候，unix domain sockets 的优势就不那么明显了。
- 当大量使用 pipelining 时候，unix domain sockets 的优势就不那么明显了。
- 当使用网络连接时，并且以太网网数据包在 1500 bytes 以下时， 将多条命令包装成 pipelining 可以大大提高效率。事实上，处理 10 bytes，100 bytes， 1000 bytes 的请求时候，吞吐量是差不多的

## 我想说
- 我分别测试我之前在腾讯云上的Redis服务器 **(Windows Server 2008R2)**  和现在在阿里云上的服务器  **(Linux CentOS 7.2)** 及 局域网下同事的Redis服务器，和本机Redis的服务器
速度最快的本机服务器，其次是同事的服务器，再次是阿里云上的服务器，最后是腾讯云上的服务器
- 测试差异之大除了在硬件上的差别外，最客观的因素在网络带宽上，我自己2个位于云上的服务器都是1M的带宽，如此测试，正如上面所说，远远不达不到数据传输所需要的带宽值

## 最后
- 参考文章：http://www.redis.cn/topics/benchmarks.html