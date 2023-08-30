---
title: IntelliJ 2023.2 版本在 MacOS 上表现卡顿问题的解决
date: 2023-08-25 11:03:29
description: IntelliJ 2023.2 版本在 MacOS 上表现卡顿问题的解决
categories: [IntelliJ IDEA篇]
tags: [IntelliJ IDEA]
---

<!-- more -->

# 解决方案
Help -> Edit Custom VM Options...

配置 `-Dsun.java2d.metal=false` 关闭 metal 的渲染，使用 OpenGL 渲染