---
title: gradle No cached version available for offline mode
date: 2019-11-13 16:23:12
description: gradle 添加新的依赖报错 No cached version available for offline mode
categories: [Gradle篇]
tags: [Gradle]
---

<!-- more -->

### 解决
在 idea 以前的版本里,在 Preferences | Build, Execution, Deployment | Gradle 去掉勾选 Offline work 即可

但是在最新版 2019.2 里,需要点击 gradle 面板里最上面一排小扳手左边一个图标,取消离线模式 