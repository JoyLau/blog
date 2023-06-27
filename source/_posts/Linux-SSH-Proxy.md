---
title: SSH 配置开启隧道的 TCP 转发
date: 2023-06-27 14:08:54
categories: [Linux篇]
tags: [linux,SSH]
---

<!-- more -->
ssh 配置开启隧道的 tcp 转发

有时我们开启 本地端口转发或者远程端口转发想在内网的其他服务器上使用该端口，修改修改 `/etc/ssh/sshd_config` 配置文件来开启转发

1. 打开配置项 **AllowTcpForwarding yes**
2. 打开配置项 **GatewayPorts yes**
3. 如果长时间保持连接，那么还需要开启 **TCPKeepAlive yes**