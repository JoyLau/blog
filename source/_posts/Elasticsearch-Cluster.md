---
title: Elasticsearch 集群搭建
date: 2018-5-7 11:48:19
description: "记录下elasticsearch集群搭建的配置"
categories: [大数据篇]
tags: [Elasticsearch]
---

<!-- more -->

## 说明
1. 机器三台
2. 彼此间内网不同，公网可通（因为这个问题花费了很长时间,配置文件里有我的理解说明）
3. 机器配置很低，需要调节jvm参数来优化
4. elasticsearch 版本为 5.3.0

## elasticsearch.yml
``` bash
    cluster.name: joylau-es
    node.name: joylau
    # 有资格作为主节点
    node.master: true
    # 节点存储数据
    node.data: true
    # 绑定的ip地址
    # 这里原来默认的是 network.host,如果配置了network.host，则一下2个配置的属性都为network.host的值
    # 集群中各个节点内网不通，集群搭建不起来的原因就在这里，我也是查阅了大量资料，花费了好长时间，才搞明白
    # 绑定地址，这里配置任何ip都能访问
    network.bind_host: 0.0.0.0
    # 这里配置该节点的公网IP地址，在集群启动时就不会使用默认内网地址寻找策略，就会以配置的公网地址来寻找该节点
    network.publish_host: ip
    #
    # Set a custom port for HTTP:
    #
    http.port: 9268
    transport.tcp.port: 9368
    #
    # For more information, consult the network module documentation.
    # 集群的各个节点配置
    discovery.zen.ping.unicast.hosts: ["ip1:9368", "ip2:9368", "ip3:9368"]
    #
    # Prevent the "split brain" by configuring the majority of nodes (total number of master-eligible nodes / 2 + 1):
    # 上句话的意思是采取过半原则的策略配置节点数，为了防止“脑裂”情况，数量建议为 (节点总数/2) + 1
    # 我的理解就是最少有多少个节点的时候开始选取主节点，这里我配置的1，比如说我现在有3个几点，其中一个节点的网络断了
    # 如果配置的2 的话，那么有2个节点的会投票选取主节点，成为一个集群，剩下的那个节点无法选取主节点而挂了
    # 如果配置的 1 的话，剩下的那个节点就会自己成为主节点而单独成为一个集群，这样就有2个集群了
    # 说了这么多，大致的意思就是这样，我是这么理解的
    #
    discovery.zen.minimum_master_nodes: 1

```

剩下没贴出配置的都是默认配置

依照改配置，在各个节点上修改节点名称及network.publish_host，要保证集群名称一样就可以了。
## jvm.options
主要配置 
     -Xms1400m
     -Xmx1400m
     
我这里的机器是2G的运存，经过我的反复调试，能给出elasticsearch最大的内存空间就是1400m了，给多了跑步起来，给少了有不能完全发挥elasticsearch的性能优势
机器差，没办法
还有一点注意的是初始化内存大小个最大内存大小的配置数值要是一样的，否则会启动出错