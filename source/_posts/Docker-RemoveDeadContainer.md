---
title: Docker 删除 状态为Dead 的容器
date: 2019-01-25 13:31:48
description: Docker 删除 状态为Dead 的容器
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### 错误信息
因为一些不正确的操作,导致容器的状态变成了 dead

``` bash
    CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS                      PORTS                                                              NAMES
    c21c993c5107        34.0.7.183:5000/joylau/traffic-service:2.1.7          "java -Djava.secur..."   2 weeks ago         Dead                                                                                           traffic-service
    dfbd1cdb31c2        34.0.7.183:5000/joylau/traffic-service-admin:1.2.1    "java -Djava.secur..."   2 weeks ago         Dead                                                                                           traffic-service-admin
    8778a28ab120        34.0.7.183:5000/joylau/traffic-service-data:2.0.4     "java -Djava.secur..."   2 weeks ago         Dead                                                                                           traffic-service-data
    65a3885e08b5        34.0.7.183:5000/joylau/traffic-service-node:1.2.3     "/bin/sh -c './nod..."   2 weeks ago         Dead                                                                                           traffic-service-node
    90700440e1df        34.0.7.183:5000/joylau/traffic-service-server:1.2.1   "java -Djava.secur..."   2 weeks ago         Dead                                                                                           traffic-service-server
    
```

这类的容器删除时会报错

``` bash
    # docker rm c21c993c5107
    Error response from daemon: Driver overlay2 failed to remove root filesystem c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64: remove /var/lib/docker/overlay2/099974dbeef827a3bbd932b7b36502763482ae8df25bd80f61a288b71b0ab810/merged: device or resource busy
```

### 解决方式
找到 filesystem 后面的字符串

``` bash
    # grep c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64 /proc/*/mountinfo
```

得到如下输出:

```bash
    /proc/28032/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28033/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28034/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28035/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28036/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28037/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28038/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28039/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28040/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28041/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28042/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28043/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28044/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28045/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28046/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28047/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
    /proc/28048/mountinfo:973 957 0:164 / /var/lib/docker/containers/c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64/shm rw,nosuid,nodev,noexec,relatime shared:189 - tmpfs shm rw,size=65536k
```

proc 和 mountinfo 中间的数字将其 kill 掉即可

写一个批量处理的脚本列出所有的 pid

``` bash
    grep c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64 /proc/*/mountinfo | awk '{print substr($1,7,5)}'
```

再 kill 掉

``` bash
    grep c21c993c51073f41653aa7fd37dbfd232f8439ca79fd4315a410d0b41d8b0e64 /proc/*/mountinfo | awk '{print substr($1,7,5)}' | xargs kill -9
```

print 是awk打印指定内容的主要命令

$0           表示整个当前行
$1           每行第一个字段,每个字段以空格隔开
substr($1,7,5) 每行第一个字段,第7个字符开始,截取5个字符

然后在 `docker rm container`

完美解决.