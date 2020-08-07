---
title: Ubuntu --- 调整状态栏托盘图标的顺序
date: 2020-08-08 15:54:55
description: 继上一篇文章 【indicator-sysmonitor 状态栏监控工具开启对磁盘读写的监控】，这里我想让监控的数据放到状态栏的最左侧， 可发现事情并不简单
categories: [Ubuntu篇]
tags: [Ubuntu]
---
<!-- more -->

### 背景
继上一篇文章 【indicator-sysmonitor 状态栏监控工具开启对磁盘读写的监控】，这里我想让监控的数据放到状态栏的最左侧， 可发现事情并不简单。。。

因为 Ubuntu 下并不像 Mac 下按住 option 键可随意拖动

### 解决方式

```bash
    sudo vim /usr/share/indicator-application/ordering-override.keyfile
```

修改顺序， 数字越小越靠左


修改完毕使用 `restart unity-panel-service` 重启生效

但发现修改完后顺序并没有改变

这个时候需要结合状态栏实际已有的托盘图标来操作顺序

获取状态栏图标的脚本：

```bash
    #!/bin/sh
     
    dbus-send --type=method_call --print-reply --dest=com.canonical.indicator.application /com/canonical/indicator/application/service com.canonical.indicator.application.service.GetApplications | grep "string" > /tmp/indicators.txt
     
    c=$(wc -l < /tmp/indicators.txt)
    i=$((c / 8))
    s=6
     
    while [ "$i" != "0" ]; do
        echo $(awk -v n=$s '/string/ && !--n {getline; print; exit}' /tmp/indicators.txt)
        s=$(( $s + 8 ))
        i=$(( $i - 1 ))
    done
```

执行这个脚本获取图标的程序名称， 再修改 `ordering-override.keyfile` 的顺序， `restart unity-panel-service` 重启生效

### 缺点
按照上述方式操作后， 顺序得以改变， 但是如果后续打开了新的程序有托盘图标， 则新程序的图标会在最左边