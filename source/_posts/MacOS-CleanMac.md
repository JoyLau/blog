---
title: MacOS 垃圾清理
date: 2018-4-1 10:32:14
description: MacOS 时间用久了，该怎么清理垃圾了，不想像 windows 那样装个 xx卫士，xx管家来清理，用2个命令就可清理
categories: [MacOS篇]
tags: [MacOS,MacBookPro]
---

<!-- more -->
GarageBand，这个是系统上的模拟乐器，一般都使用不到

``` bash
    rm -rf /Library/Application\ Support/GarageBand
    rm -rf /Library/Application\ Support/Logic
    rm -rf /Library/Audio/Apple\ Loops
```

但是有些系统文件显示占用的空间很大，该怎么看呢

``` bash
    du -sh *
```

这个命令用来查看根目录下，所有文件的大小分布

比如，我的电脑 Library 文件路径最大

那就在进入 Library 文件路径，再执行 du -sh *

直至找到占用内存最大的文件,然后结合实际情况,进行删减