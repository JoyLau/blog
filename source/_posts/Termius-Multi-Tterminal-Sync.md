---
title: Termius 多终端软件配置手动同步
date: 2020-09-27 15:02:15
description: Termius 多终端软件配置手动同步
categories: [工具类篇]
tags: [Termius]
---

<!-- more -->

Termius 算是我比较喜欢的一款终端软件了, 因为它很漂亮, 自带的字体很好看, 软件本身是免费的, 但是如果要使用一些高级功能

比如不同操作系统下的 Termius 的软件配置同步则需要订阅他的高级功能, 收费不低, 关键还不是买断机制的, 是按年缴费

这不得不使我研究了一番

### 解决
经我研究, Termius 是使用 Electron 开发的, 挂不得它可以把界面做的这么好看

我本身也使用 Electron 开发过一些加壳软件, 知道软件的一些配置信息存储的技术手段

1. 本地文件存储
2. cookie 存储
3. Local Storage 存储
4. IndexedDB 存储

其中第二,第三的方式存储不太可能, 是一些简单的字符串存储, 容量小, 且数据结构简单

最终我定位了它使用的是 IndexedDB 存储

且存储的位置(Mac OS)在 `/Users/joylau/Library/Containers/com.termius.mac/Data/Library/Application Support/Termius/IndexedDB/file__0.indexeddb.leveldb/000003.log`

同理在 Windows 下或者 Linux 下找到该 indexedDB 数据文件, 再进行替换, 则软件的配置得以同步

