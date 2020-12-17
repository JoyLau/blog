---
title: 关于 Docker -p 穿透防火墙 firewalld 的问题的研究记录
date: 2020-12-17 11:16:30
description: 关于 Docker -p 穿透防火墙 firewalld 的问题的研究记录
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### 背景
使用 docker run -p 或者 docker compose 启动暴露的端口的容器, 会直接穿透防火墙, 不受系统防火墙的 firewalld 的管控

### 原因
docker 容器会在启动的时候向 iptables 添加转发的规则
而 firewalld 也是通过操作 iptables 来实现的防火墙的功能

```bash
    [root@centOS7 es-test]# iptables -L DOCKER
    Chain DOCKER (3 references)
    target     prot opt source               destination         
    ACCEPT     tcp  --  anywhere             172.18.0.2           tcp dpt:xic
    ACCEPT     tcp  --  anywhere             172.20.0.2           tcp dpt:vrace
    ACCEPT     tcp  --  anywhere             172.20.0.2           tcp dpt:wap-wsp

```

可以看到是 anywhere


### 解决方式

#### 第一种 禁用 docker 操作 iptables
在 /etc/docker/daemon.json 配置禁用 iptables: 

```json
    {"iptables": false}

```

之后重启 docker 服务, 可以看到 docker 不会自动往 iptables 里添加规则了


这种方式有个弊端: 就是容器之间无法互相访问, 而且容器里的程序也无法访问外部网络

解决方式:
在防火墙里开始 net 转发:

配置 /etc/firewalld/zones/public.xml

```xml
    <zone>
      <short>Public</short>
      <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
      <service name="ssh"/>
      <service name="dhcpv6-client"/>
      <masquerade/> 
    </zone>
```

或者使用下面的方式添加 iptables 规则

```bash 
    firewall-cmd --zone=public --add-masquerade
```

之后使用 firewall-cmd --restart 或者 systemctl restart firewalld 使配置生效即可

但是这样做还有个问题, 就是所有访问容器的程序对于容器来说 IP 的变成的网关的 IP
这样的问题对于一些需要特定限制一些 IP 地址来源的应用和使用 IP 地址来作区分的应用来说就有很大问题, 比如注册中心
目前没有找到什么方式解决这个问题

#### 第二种 容器直接指定主机网络
docker run 的时候不显式暴露端口 -p 什么的, 使用 --net host 的形式直接将容器的端口绑定到宿主机上

docker compose 运行的时候使用:

```yaml
    version:  '3.2'
    services:
      abc:
        network_mode: "host"
```
