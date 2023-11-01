---
title: Linux --- 快速复制大量小文件
date: 2023-09-07 18:39:38
description: Linux 快速复制大量小文件
categories: [Linux篇]
tags: [Linux,CMD]
---

<!-- more -->
## 步骤
有时需要进行数据的备份和恢复， 涉及到大量的小文件拷贝， 速度很慢，找了一个速度相对较快的命令来操作， 记录下

```shell
  cd source/; tar cf - . | (cd target/; tar xvf -)
```
