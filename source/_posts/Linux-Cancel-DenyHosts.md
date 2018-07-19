---
title: DenyHosts 清除黑名单 IP 地址
date: 2018-07-19 10:47:25
description: 今天连接远程服务器发生了错误,我想应该是我当前的 IP 地址被 DenyHosts 加入了黑名单,想取消的话还是花了一点的功夫
categories: [Linux篇]
tags: [Linux]
---

<!-- more -->
## 背景
今天连接远程服务器发生了以下的错误
``` bash
    ssh_exchange_identification: read: Connection reset
```

我想应该是我当前的 IP 地址被 DenyHosts 加入了黑名单
本来想只要将当前的 ip 地址在黑名单中去掉就可以了
没想到事实并不是如此,为此还查资料花费了一点功夫
现记录下来

## 解决
1. 停用 DenyHosts : `systemctl stop denyhosts.service`
2. 删除黑名单中当前的ip地址: `vim /etc/hosts.deny`
3. 进入  `/var/lib/denyhosts`

``` bash
      -rw-r--r-- 1 root root    39 2月  16 2015 allowed-hosts
      -rw-r--r-- 1 root root 71451 7月  19 10:58 hosts
      -rw-r--r-- 1 root root 71270 7月  19 10:58 hosts-restricted
      -rw-r--r-- 1 root root 71433 7月  19 10:58 hosts-root
      -rw-r--r-- 1 root root 71280 7月  19 10:58 hosts-valid
      -rw-r--r-- 1 root root   105 7月  19 10:58 offset
      -rw-r--r-- 1 root root     0 7月  19 10:58 suspicious-logins
      -rw-r--r-- 1 root root 44731 7月  19 10:58 users-hosts
      -rw-r--r-- 1 root root 50925 7月  19 10:58 users-invalid
      -rw-r--r-- 1 root root   643 7月  19 10:58 users-valid
```

4. 依次在上面各个文件中移除自己当前的IP地址
5. 如果要将当前的IP地址添加到白名单中,可以在 /etc/hosts.allow 添加
   sshd: ip地址
   allowed-hosts 添加 IP地址
6. 重启 DenyHosts

> 注意: 这些文件里有很多被拉入黑名单的IP地址,vim编辑的时候可以在命令行模式下使用 `/ip地址` 来查找, n 和 N 上下翻动,再在命令行模式下 `:noh` 取消查找