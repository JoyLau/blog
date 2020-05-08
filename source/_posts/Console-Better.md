---
title: 让你的Windows控制台窗口更优美
date: 2017-6-16 09:23:17
cover: //image.joylau.cn/blog/console-better.png
description: Windows下默认的控制台字体简直丑爆了
categories: [其他篇]
tags: [CMD]
---

<!-- more -->


Windows下最适合编程的字体要数`Consolas`字体了，那么如何将命令提示符换成Consolas字体呢？我们只需要注册以下信息即可:

``` bash
    Windows Registry Editor Version 5.00
    [HKEY_CURRENT_USER\Console\%SystemRoot%_system32_cmd.exe]
    "WindowSize"=dword:00170058
    "ScreenBufferSize"=dword:01170058
    "WindowPosition"=dword:0079004b
    "ColorTable01"=dword:00235600
    "FontSize"=dword:00120000
    "FontWeight"=dword:00000190
    "FaceName"="Consolas"
    "FontFamily"=dword:00000036
```


新建一个文本文件，将信息保存到此文本文件中
然后将文本文件重命名为*.reg
双击此文件将其注册