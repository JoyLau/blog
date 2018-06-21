---
title: Elasticsearch 配置说明 && 遇坑记录
date: 2017-10-25 14:49:54
description: "在这留一份 elasticsearch.yml 的配置文件说明，以备查询"
categories: [大数据篇]
tags: [Elasticsearch]
---

<!-- more -->

## 配置说明
    配置Elasticsearch的集群名称，默认是elasticsearch，Elasticsearch会自动发现在同一网段下的Elasticsearch 节点，如果在同一网段下有多个集群，就可以用这个属性来区分不同的集群。
    cluster.name: elasticsearch
    
    节点名，默认随机指定一个name列表中名字，不能重复。
    node.name: "node1"
    
    指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
    node.master: true
    
    指定该节点是否存储索引数据，默认为true。
    node.data: true
    
    设置默认索引分片个数，默认为5片。
    index.number_of_shards: 5
    
    设置默认索引副本个数，默认为1个副本。
    index.number_of_replicas: 1
    
    设置配置文件的存储路径，默认是es根目录下的config文件夹。
    path.conf: /path/to/conf
    
    设置索引数据的存储路径，默认是es根目录下的data文件夹
    path.data: /path/to/data
    
    可以设置多个存储路径，用逗号（半角）隔开，如下面这种配置方式：
    path.data: /path/to/data1,/path/to/data2
    
    设置临时文件的存储路径，默认是es根目录下的work文件夹。
    path.work: /path/to/work
    
    设置日志文件的存储路径，默认是es根目录下的logs文件夹
    path.logs: /path/to/logs
    
    设置插件的存放路径，默认是es根目录下的plugins文件夹
    path.plugins: /path/to/plugins
    
    设置为true来锁住内存。因为当jvm开始swapping时es的效率会降低，所以要保证它不swap，可以把ES_MIN_MEM和ES_MAX_MEM两个环境变量设置成同一个值，并且保证机器有足够的内存分配给es。同时也要允许elasticsearch的进程可以锁住内存，linux下可以通过`ulimit -l unlimited`命令。
    bootstrap.mlockall: true
    
    设置绑定的ip地址，可以是ipv4或ipv6的，默认为0.0.0.0。
    network.bind_host: 192.168.0.1
    
    设置其它节点和该节点交互的ip地址，如果不设置它会自动判断，值必须是个真实的ip地址。
    network.publish_host: 192.168.0.1
    
    这个参数是用来同时设置bind_host和publish_host上面两个参数。
    network.host: 192.168.0.1
    
    设置节点间交互的tcp端口，默认是9300，（集群的时候，注意端口区分）。
    transport.tcp.port: 9300
    
    设置是否压缩tcp传输时的数据，默认为false，不压缩。
    transport.tcp.compress: true
    
    设置对外服务的http端口，默认为9200（集群的时候，同台机器，注意端口区分）。
    http.port: 9200
    
    设置内容的最大容量，默认100mb
    http.max_content_length: 100mb
    
    是否使用http协议对外提供服务，默认为true，开启。
    http.enabled: false
    
    gateway的类型，默认为local即为本地文件系统，可以设置为本地文件系统，分布式文件系统，hadoop的HDFS，和amazon的s3服务器。
    gateway.type: local
    
    设置集群中N个节点启动时进行数据恢复，默认为1。
    gateway.recover_after_nodes: 1
    
    设置初始化数据恢复进程的超时时间，默认是5分钟。
    gateway.recover_after_time: 5m
    
    设置这个集群中节点的数量，默认为2，一旦这N个节点启动，就会立即进行数据恢复。
    gateway.expected_nodes: 2
    
    初始化数据恢复时，并发恢复线程的个数，默认为4。
    cluster.routing.allocation.node_initial_primaries_recoveries: 4
    
    添加删除节点或负载均衡时并发恢复线程的个数，默认为4。
    cluster.routing.allocation.node_concurrent_recoveries: 2
    
    设置数据恢复时限制的带宽，如入100mb，默认为0，即无限制。
    indices.recovery.max_size_per_sec: 0
    
    设置这个参数来限制从其它分片恢复数据时最大同时打开并发流的个数，默认为5。
    indices.recovery.concurrent_streams: 5
    
    设置这个参数来保证集群中的节点可以知道其它N个有master资格的节点。默认为1，对于大的集群来说，可以设置大一点的值（2-4）
    discovery.zen.minimum_master_nodes: 1
    
    设置集群中自动发现其它节点时ping连接超时时间，默认为3秒，对于比较差的网络环境可以高点的值来防止自动发现时出错。
    discovery.zen.ping.timeout: 3s
    
    设置是否打开多播发现节点，默认是true。
    discovery.zen.ping.multicast.enabled: false
    
    设置集群中master节点的初始列表，可以通过这些节点来自动发现新加入集群的节点。
    discovery.zen.ping.unicast.hosts: ["host1", "host2:port", "host3[portX-portY]"]



低配置云服务器上安装遇到的坑：
1. 启动elasticsearch直接退出，并返回killed，这里一般是由于内存不足导致的
   修改es_home/config/jvm.options
   -Xms2g
   -Xmx2g

2. max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]解决办法是手动修改/etc/sysctl.conf文件，最后面加上一行代码。
   vm.max_map_count=655360
   修改/etc/sysctl.conf，修改完成之后，参数可以使用sysctl -p命令来让参数生效
   
3. initial heap size [536870912] not equal to maximum heap size [1073741824]; this can cause resize pauses and prevents mlockall from locking the entire heap
    vi config/jvm.options 
    -Xms 和 -Xmx需要配置的相等，不然无法启动成功
    
【更新一下内容 2018年4月28日】

4. elasticsearch 5 版本以上不能以  root 用户启动，需要新建一个用户
    useradd elasticsearch
    passwd elasticsearch
    chown elasticsearch path -R
    
5. elasticsearch 在 linux 下以后台启动的命令
    sh elasticsearch -d
    确认日志没有报错，然后head插件可以连接的上就可以了



### 2018-06-21 更新
1. ElasticSearch 允许跨域
    http.cors.enabled: true #开启跨域访问支持，默认为false  
    http.cors.allow-origin: /.*/ #跨域访问允许的域名地址，(允许所有域名)以上使用正则
  
2. rpm 安装的 elasticsearch 可以自动以系统服务启动和以root用户启动