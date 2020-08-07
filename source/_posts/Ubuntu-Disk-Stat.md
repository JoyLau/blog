---
title: Ubuntu --- indicator-sysmonitor 状态栏监控工具开启对磁盘读写的监控
date: 2020-08-07 15:06:08
description: indicator-sysmonitor 默认的模式可以监控 CPU 使用率， 内存使用， 网络 I/O 等， 但是却缺少了很关键的对当前磁盘 I/O 的监控，于是我就想着把他给加上去
categories: [Ubuntu篇]
tags: [Ubuntu]
---
<!-- more -->

### 背景
indicator-sysmonitor 默认的模式可以监控 CPU 使用率， 内存使用， 网络 I/O 等， 但是却缺少了很关键的对当前磁盘 I/O 的监控，于是我就想着把他给加上去

### 解决方式
indicator-sysmonitor 可以新建传感器，可以自定义命令来显示输出， 于是我想着使用 shell 命令获取当前磁盘的 I/O 在输出即可

### dstat 方式
1. 使用 `dstat` 命令， 需要机器上事先安装 `dstat` 

```shell 
    dstat  --disk
```

该命令可以监控磁盘使用情况

我在稍对结果做下过滤的优化， 使用下面的命令

```shell 
    dstat  --disk 1 1 | sed -n '4p' | awk '{printf "r: "}{printf $1}{printf "   w: "}{printf $2}'
```

上述的命令的解释为 1s 输出一次， 一次输出一行， 取第四行， 取第一列和第二列，在加上读写的标识 `r:` 和 `w:` 的前缀

输出的结果为：

```text
    r: 0   w: 6244kj
```

在 indicator-sysmonitor 里新建一项， 复制上述命令，效果如下

![disk-dstat](http://image.joylau.cn/blog/stat-disk_001.png)



### iotop

1. 使用 `iotop` 命令， 需要机器上事先安装 `iotop` 

```shell
    sudo iotop
```

在美化下输出结果：

```bash
    sudo iotop -o -b -n 1 | sed -n '2p' | awk '{printf "r: "}{printf  $4 $5}{printf "  w: "}{printf $10 $11}'
```

命令的意思同上

输出的结果为：

```text
    r: 0.00B/s  w: 0.00B/s

```

同上操作， 命令更换下，效果如下：

![disk-iotop](http://image.joylau.cn/blog/stat-disk_002.png)


### 对比
1. 输出单位不一样，第一种方式单位只有 k,m 这样的， 第二种是 B/s, KB/s, MB/s 这样的， 不过第一种方式的单位也可以手动给补全上
2. 第一种方式 `dstat` 命令不需要 root 权限即可执行， 第二种方式 `iotop` 命令需要 root 权限即需要加 `sudo`

使用 sudo 的常用方式为：

```bash
    echo "你的 root 的密码" | sudo iotop ....
```

但是这样的方式在终端执行可以输出结果， 在 indicator-sysmonitor 执行却不能输出结果。。。。。

于是需要解决这个问题， 即使用普通用户执行 `iotop` 命令时不需要输入密码

这里我的解决方案如下：

```bash
    sudo visudo

    ## 添加下面几行
    User_Alias NET_USERS = joylau

    Cmnd_Alias SYS_STATUS = /usr/sbin/iotop # 多个命令逗号隔开

    NET_USERS ALL=(root)   NOPASSWD:SYS_STATUS
```

`Ctrl + O ` 保存后，普通用户 joylau 使用 `sudo iotop` 就不需要输入密码了， 也就实现了第二种方式的效果了


3. 性能对比： 实测第一种方式的性能（CPU使用平均在 2%）要稍好于第二种（CPU使用平均在 5%）