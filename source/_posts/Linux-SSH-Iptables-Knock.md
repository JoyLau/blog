---
title: 使用 iptables + ping 临时开启 SSH 22 端口的远程连接
date: 2025-01-10 14:39:06
description: 有时我们会远程连接服务器，但是不希望其他人能通过 22 端口连接，下面是一种处理方式
categories: [Linux篇]
tags: [Linux,iptables]
---

有时我们会远程连接服务器，但是不希望其他人能通过 22 端口连接，下面是一种处理方式
通过特殊的操作先对服务器进行敲门，暗号对上了才开放远程连接，之后再关闭后面的连接

<!-- more -->
## 脚本命令

```shell
# 指定IP能访问22端口
iptables -A INPUT -s ip1,ip2 -p tcp --dport 22 -j ACCEPT
# 接受 1078字节的ping包，并将源IP记录到自定义名为sshKeyList的列表中
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -m length --length 1078 -m recent --name sshKeyList --set -j ACCEPT
# 若30秒内发送次数达到6次(及更高)，拒绝22端口的访问
iptables -A INPUT -p tcp -m tcp --dport 22 --syn -m recent --name sshKeyList --rcheck --seconds 30 --hitcount 6 -j DROP
# 若30秒内发送次数达到5次，允许22端口访问
iptables -A INPUT -p tcp -m tcp --dport 22 --syn -m recent --name sshKeyList --rcheck --seconds 30 --hitcount 5 -j ACCEPT
# 对于已建立的连接放行
iptables -A INPUT -m state --state ESTABLISHED -p tcp -m tcp --dport 22 -j ACCEPT
# 其他的拒绝22端口访问
iptables -A INPUT -p tcp -m tcp --dport 22 -j DROP
```

## 使用方法
1. 先在本地使用 ping 命令 ping 服务器，发送指定大小的包  

```shell
 # 发送大小为1050字节的ping包，发5次
 ping serverip -n 5 -l 1050
```

2. 连接服务器