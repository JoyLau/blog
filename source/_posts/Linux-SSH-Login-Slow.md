---
title: SSH 登录慢解决方法
date: 2024-03-19 09:29:00
categories: [Linux篇]
tags: [linux,SSH]
---

<!-- more -->
记录下 ssh 登录慢的解决方案

修改配置文件 `/etc/ssh/sshd_config`

#### 关闭 DNS 反向解析
```shell
UseDNS no
```

#### 关闭 gssapi 认证
```shell
GSSAPIAuthentication no
```
