---
title: Docker 启动报错： Error starting daemon： Error initializing network controller： list bridge addresses failed： no available network
date: 2019-04-08 17:15:06
description: Error starting daemon： Error initializing network controller： list bridge addresses failed： no available network
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## 背景

Docker 启动报错： Error starting daemon: Error initializing network controller: list bridge addresses failed: no available network

## 错误详情

查看错误日志： `journalctl -xe | grep docker`

```bash
    [root@lenovo docker]# journalctl -xe | grep docker
    -- Subject: Unit docker.socket has begun start-up
    -- Unit docker.socket has begun starting up.
    -- Subject: Unit docker.socket has finished start-up
    -- Unit docker.socket has finished starting up.
    -- Subject: Unit docker.service has begun start-up
    -- Unit docker.service has begun starting up.
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.909025064+08:00" level=info msg="parsed scheme: \"unix\"" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.909923898+08:00" level=info msg="scheme \"unix\" not registered, fallback to default scheme" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.910865280+08:00" level=info msg="parsed scheme: \"unix\"" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.910909267+08:00" level=info msg="scheme \"unix\" not registered, fallback to default scheme" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.928785984+08:00" level=info msg="ccResolverWrapper: sending new addresses to cc: [{unix:///run/containerd/containerd.sock 0  <nil>}]" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.928902169+08:00" level=info msg="ClientConn switching balancer to \"pick_first\"" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.929039549+08:00" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc420606e00, CONNECTING" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.937533340+08:00" level=info msg="ccResolverWrapper: sending new addresses to cc: [{unix:///run/containerd/containerd.sock 0  <nil>}]" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.937601232+08:00" level=info msg="ClientConn switching balancer to \"pick_first\"" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.937707487+08:00" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc42015bf00, CONNECTING" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.950807950+08:00" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc42015bf00, READY" module=grpc
    4月 08 16:42:09 lenovo dockerd[1742]: time="2019-04-08T16:42:09.952160247+08:00" level=info msg="pickfirstBalancer: HandleSubConnStateChange: 0xc420606e00, READY" module=grpc
    4月 08 16:42:10 lenovo dockerd[1742]: time="2019-04-08T16:42:10.216864045+08:00" level=info msg="Graph migration to content-addressability took 0.00 seconds"
    4月 08 16:42:10 lenovo dockerd[1742]: time="2019-04-08T16:42:10.218710988+08:00" level=info msg="Loading containers: start."
    4月 08 16:42:10 lenovo dockerd[1742]: Error starting daemon: Error initializing network controller: list bridge addresses failed: no available network
    4月 08 16:42:10 lenovo systemd[1]: docker.service: main process exited, code=exited, status=1/FAILURE
    -- Subject: Unit docker.service has failed
    -- Unit docker.service has failed.
    4月 08 16:42:10 lenovo systemd[1]: Unit docker.service entered failed state.
    4月 08 16:42:10 lenovo systemd[1]: docker.service failed.
    4月 08 16:42:13 lenovo systemd[1]: docker.service holdoff time over, scheduling restart.
    -- Subject: Unit docker.socket has begun shutting down
    -- Unit docker.socket has begun shutting down.
    -- Subject: Unit docker.socket has begun start-up
    -- Unit docker.socket has begun starting up.
    -- Subject: Unit docker.socket has finished start-up
    -- Unit docker.socket has finished starting up.
    -- Subject: Unit docker.service has begun start-up
    -- Unit docker.service has begun starting up.

```

看到这样一句话： **Error starting daemon: Error initializing network controller: list bridge addresses failed: no available network**


查看本机网络： `ip a`

```bash
    [root@lenovo docker]# ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    2: enp7s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
        link/ether b8:70:f4:24:61:a7 brd ff:ff:ff:ff:ff:ff
    3: wlp8s0b1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
        link/ether cc:af:78:25:31:51 brd ff:ff:ff:ff:ff:ff
        inet 192.168.10.145/24 brd 192.168.10.255 scope global noprefixroute wlp8s0b1
           valid_lft forever preferred_lft forever
        inet6 fe80::8de1:5b7d:b7d7:2788/64 scope link noprefixroute 
           valid_lft forever preferred_lft forever
    4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
        link/none 
        inet 192.168.255.10 peer 192.168.255.9/32 scope global tun0
           valid_lft forever preferred_lft forever
        inet6 fe80::e41d:195:f566:33e1/64 scope link flags 800 
           valid_lft forever preferred_lft forever

```

没有 docker0 的桥接网络

手动添加一个即可

## 解决

```bash
    ip link add name docker0 type bridge
    ip addr add dev docker0 172.17.0.1/16
```

再看一下，多了一个 docker0

```bash
    5: docker0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
        link/ether a6:7d:d7:94:ab:f3 brd ff:ff:ff:ff:ff:ff
        inet 172.17.0.1/16 scope global docker0
           valid_lft forever preferred_lft forever

```

重启 docker 即可