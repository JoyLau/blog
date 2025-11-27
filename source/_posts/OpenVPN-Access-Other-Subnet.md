---
title: OpenVPN 客户端访问其他客户端的子网段的解决方案
date: 2025-11-25 13:45:15
description: 含 NAT、路由与 iptables 配置
categories: [OpenVPN篇]
tags: [OpenVPN]
---


在使用 OpenVPN 进行异地互联的场景中，经常会遇到这样的需求：

OpenVPN 的客户端 A（192.168.250.5）需要访问客户端 B 所在的其他子网（如 26.64.10.x）。

OpenVPN 本身的虚拟网段为：

```
192.168.250.0/24
```


但客户端 B 还连接着一个生产网络：

<!-- more -->


```
26.64.10.0/24
```

目标是实现：

```
客户端 A === OpenVPN ===> 客户端 B ===> 26.64.10.x
```

同时 **不能修改 26.64.10.x 网络的网关和路由**，也即必须保证生产网段无变动。

本文将介绍从路由、iptables、NAT 到最终验证的完整解决方案。


## 📌 1. 需求分析与拓扑结构

假设环境：

* OpenVPN 服务器分配的虚拟网段：**192.168.250.0/24**
* 客户端 A：**192.168.250.5**
* 客户端 B：**192.168.250.121**
* B 可访问其局域网：**26.64.10.0/24**
* A 希望访问：**26.64.10.x（如 26.64.10.121）**

由于目标子网的网关无法修改访问 192.168.250.x 的路径，若没有 NAT，26.64.10.x 的回包会找不到路线。

因此必须使用：

* **路由**（告诉 A/B/Server 如何走）
* **iptables FORWARD 放行**
* **NAT（MASQUERADE）伪装来源 IP，让回包自动返回 B**

这也是企业环境常见的 VPN 到局域网互访方案。

---

## 📌 2. 在客户端 A 上添加静态路由

A 需要知道访问 26.64.10.0/24 时走 VPN（tun1）：

```
route 26.64.10.0 255.255.255.0 vpn_gateway
```

这表示：

> 去 26.64.10.x 的流量全部通过 OpenVPN 发给服务器/B。

---

## 📌 3. 在客户端 B 上开启数据转发

```
echo 1 > /proc/sys/net/ipv4/ip_forward
```

持久化：

```
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

---

## 📌 4. 在客户端 B 上放行 tun1 的转发流量

客户端 B 是 VPN 流量与内网 26.64.10.x 的中转节点，因此必须允许 FORWARD。

```
iptables -I FORWARD -i tun1 -j ACCEPT
iptables -I FORWARD -o tun1 -j ACCEPT
```

这两条代表：

* OpenVPN → 内网允许
* 内网 → OpenVPN 允许

这里的 tun1 是 openvpn 的虚拟网卡，有可能是 tun0

---

## 📌 5. **关键步骤**：在客户端 B 上启用 NAT（解决回包问题）

由于 26.64.10.x 的网关无法配置路由，因此当它看到来自 192.168.250.x 的流量，会把回包发错路径。

解决方法是 NAT：

```
iptables -t nat -A POSTROUTING -s 192.168.250.0/24 -d 26.64.10.0/24 -j MASQUERADE
```

MASQUERADE 的作用是：

> **把来自 A 的 192.168.250.x 的包伪装成 B 的本机 IP（如 26.64.10.121）。**
> 因此 26.64.10.x 的设备会把回包自动返回 B，而不会尝试回 192.168.250.x。

这是整个方案中最核心的一步。

---

## 📌 6. 验证配置

在客户端 A 上：

```
ping 26.64.10.121
```

如果收到回包，则链路已经完全打通：

```
A → tun1 → OpenVPN → B → 内网 26.64.10.x
26.64.10.x → B → tun1 → A
```

实践结果显示：

* A 能访问 B 的内网
* NAT 生效
* 无需修改 26.64.10 网段的网关

---


## 📌 7. Docker 环境的注意事项

如果 B 上运行 Docker，FORWARD 链通常由 Docker 修改，伴随：

* DOCKER-USER
* DOCKER
* DOCKER-ISOLATION

你已经看到大量 Docker 相关链（如 br-aceXXX、docker0），这很正常。

你的 tun1 规则需要插入在所有 Docker 链之前，因此使用：

```
iptables -I FORWARD ...
```

是正确处理方式。

---


### ✔ 完整配置列表（客户端 B）

```
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -I FORWARD -i tun1 -j ACCEPT
iptables -I FORWARD -o tun1 -j ACCEPT

iptables -t nat -A POSTROUTING -s 192.168.250.0/24 -d 26.64.10.0/24 -j MASQUERADE
```

### ✔ 客户端 A

```
route 26.64.10.0 255.255.255.0 vpn_gateway
```

### ✔ OpenVPN 服务端
1）server.conf：

```
route 26.64.10.0 255.255.255.0
```

有一个客户端负责 26.64.10.0/24 网段的流量，服务器以后看到去该网段的包时别丢掉，而是往对应客户端转发。

2）ccd/clientB：

```
iroute 26.64.10.0 255.255.255.0
```

route + iroute 才能让 OpenVPN 知道：
route：存在这样一个网段
iroute：由哪个客户端负责
否则服务器根本不知道该把流量发给谁  





