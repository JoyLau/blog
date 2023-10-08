---
title: MacOS 上使用命令行查看显卡风扇速度和温度
date: 2023-10-08 09:06:14
description: MacOS 上使用命令行查看显卡风扇速度和温度
categories: [MacOS篇]
tags: [MacOS]
---

<!-- more -->
```shell
  ioreg -l |grep \"PerformanceStatistics\" | cut -d '{' -f 2 | tr '|' ',' | tr -d '}' | tr ',' '\n'|grep 'Temp\|Fan'
```

显示如下：

```shell
"Fan Speed(%)"=17
"Fan Speed(RPM)"=0
"Temperature(C)"=49
```