---
title: 使用 Windows 自带的命令行工具进行端口转发
date: 2024-03-21 11:55:34
categories: [Windows篇]
tags: [windows]
---

<!-- more -->
### 配置转发

```shell
netsh interface portproxy add v4tov4 listenport=[监听端口号] listenaddress=[本地IP地址] connectport=[目标端口号] connectaddress=[目标IP地址]
```

### 查看配置

```shell
netsh interface portproxy show all
```

### 删除配置

```shell
netsh interface portproxy delete v4tov4 listenport=[监听端口号] listenaddress=[本地IP地址]
```