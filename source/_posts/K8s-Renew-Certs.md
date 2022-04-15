---
title: k8s 1.20 证书过期续签
date: 2022-04-15 15:54:28
description: k8s 1.20 证书过期续签
categories: [K8s篇]
tags: [K8s]
---

<!-- more -->

### 查看证书有效期
`kubeadm alpha certs check-expiration`

### 更新证书，如果是HA集群模式，所有master需要执行
`kubeadm alpha certs renew all`

### 证书过期kubectl命令无法使用
`cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config`


查看 kubectl 命令是否可用

如果不可用的话，使用下面命令重启 kube-apiserver, kube-controller-manager, kube-scheduler、etcd

`docker ps | grep -v pause | grep -E "etcd|scheduler|controller|apiserver" | awk '{print $1}' | awk '{print "docker","restart",$1}' | bash
`