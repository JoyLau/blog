---
title: Prometheus --- 物理机安装 node_exporter
date: 2021-05-12 09:37:26
description: 物理机安装 node_exporter
categories: [Prometheus篇]
tags: [Prometheus]
---

<!-- more -->

### 步骤
https://copr.fedorainfracloud.org/coprs/ibotty/prometheus-exporters/

curl -Lo /etc/yum.repos.d/_copr_ibotty-prometheus-exporters.repo https://copr.fedorainfracloud.org/coprs/ibotty/prometheus-exporters/repo/epel-7/ibotty-prometheus-exporters-epel-7.repo

yum -y install node_exporter

systemctl enable node_exporter

systemctl start node_exporter

echo "success"

关闭机器防火墙：

systemctl stop firewalld.service

systemctl disable firewalld.service