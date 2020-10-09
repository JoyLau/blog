---
title: CentOS 7 安装 bpytop 记录
date: 2020-10-09 10:07:44
description: 在 CentOS 8 上安装 bpytop 很简单, 安装 epel 库后执行 `dnf install bpytop` 即可, 但是在 CentOS 7 的 epel 库里却没有这个 bpytop 包
categories: [Linux篇]
tags: [Linux]
---

<!-- more -->

### 概述
在 CentOS 8 上安装 bpytop 很简单, 安装 epel 库后执行 `dnf install bpytop` 即可, 但是在 CentOS 7 的 epel 库里却没有这个 bpytop 包, 这里介绍如何在 CentOS 7 下安装 bpytop

### 步骤
1. 安装 epel 库

``` bash
    yum install epel-release
```

2. 安装 snapd 并启用 snapd 套接字

```bash
    yum install snapd
    systemctl enable --now snapd.socket
```

3. 创建符号链接

```bash
    ln -s /var/lib/snapd/snap /snap
```

4. 安装及权限配置

```shell
    snap install bpytop

    sudo snap connect bpytop:mount-observe
    
    sudo snap connect bpytop:network-control
    
    sudo snap connect bpytop:hardware-observe
    
    sudo snap connect bpytop:system-observe
    
    sudo snap connect bpytop:process-control
    
    sudo snap connect bpytop:physical-memory-observe
```