---
title: Docker 限制容器端口只对指定段 IP 开启访问
date: 2024-07-25 10:52:04
description: Docker 限制容器端口只对指定段 IP 开启访问
categories: [Docker篇]
tags: [Docker]
---


之前写过一篇 【[关于 Docker -p 穿透防火墙 firewalld 的问题的研究记录](https://blog.joylau.cn/2020/12/17/Docker-Passed-Firewalld/)】
当时没有彻底解决问题，这次又遇到相同的场景，这次是遇到三级等保扫描，想着关闭对外的访问避免被扫到，这里记录彻底解决问题的方式

<!-- more -->
### 解决
参考官方文档: https://docs.docker.com/network/packet-filtering-firewalls/#port-publishing-and-mapping

主要是限制容器与外部连接

比如限制 MySQL 容器的 3306 端口只能在固定的 IP 访问

```shell
iptables -I DOCKER-USER -m iprange -i eth0 ! --src-range 28.64.17.10-28.64.17.22 -p tcp --dport 3306 -j DROP
```

这里注意需要指定网卡， 可以使用 ` ip a` 查看

如果指定多个端口可以使用

```shell
iptables -I DOCKER-USER -m iprange -i eth0 ! --src-range 28.64.17.10-28.64.17.22 -p tcp -m multiport --dports 8080,8087,8090:8095 -j DROP
```

删除规则的话，使用

```shell
iptables -L DOCKER-USER -nv --line-numbers

iptables -D DOCKER-USER 要删除的行号
```

### 注意
上面的端口要填写容器的端口而不是映射到宿主机的端口